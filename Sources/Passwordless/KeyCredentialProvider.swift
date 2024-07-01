import AuthenticationServices
import Foundation
import OSLog

class KeyCredentialProvider: NSObject  {
    private let relyingPartyIdentifier: String
    private var authController: ASAuthorizationController?
    private var isRunning = false
    private var registrationContinuation: CheckedContinuation<ASAuthorizationPlatformPublicKeyCredentialRegistration, Error>?
    private var assertionContinuation: CheckedContinuation<ASAuthorizationPlatformPublicKeyCredentialAssertion, Error>?
    private var cancelContinuation: CheckedContinuation<Void, Never>?

    init(relyingPartyIdentifier: String) {
        self.relyingPartyIdentifier = relyingPartyIdentifier
    }

    func requestAuthorization(registerResponse: RegisterBeginResponse) async throws -> ASAuthorizationPlatformPublicKeyCredentialRegistration {
        await cancelExistingRequest()

        Logger().info("Apple Authorization for registration is running")

        guard let challenge = registerResponse.data.challenge.base64URLDecodedData() else {
            throw PasswordlessClientError.internalErrorUnableToDecodeChallenge
        }
        guard let userId = registerResponse.data.user.id.data(using: .utf8) else {
            throw PasswordlessClientError.internalErrorUnableToEncodeUserId
        }
        let name = registerResponse.data.user.name

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: name, userID: userId)
        authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController?.delegate = self
        authController?.presentationContextProvider = self

        return try await withCheckedThrowingContinuation { continuation in
            isRunning = true
            registrationContinuation = continuation
            authController?.performRequests()
        }
    }

    func requestAssertion(
        signInResponse: SignInBeginResponse,
        autoFill: Bool
    ) async throws -> ASAuthorizationPlatformPublicKeyCredentialAssertion {
        await cancelExistingRequest()

        Logger().info("Apple Assertion for sign in running(autofill: \(autoFill))")

        guard let challenge = signInResponse.data.challenge.base64URLDecodedData() else {
            throw PasswordlessClientError.internalErrorUnableToDecodeChallenge
        }

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)
        let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
        authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController?.delegate = self
        authController?.presentationContextProvider = self

        return try await withCheckedThrowingContinuation { continuation in
            isRunning = true
            assertionContinuation = continuation
            if autoFill {
                authController?.performAutoFillAssistedRequests()
            } else {
                authController?.performRequests()
            }
        }
    }

    func cancelExistingRequest() async {
        if isRunning {
            await withCheckedContinuation { continuation in
                cancelContinuation = continuation
                authController?.cancel()
            }
        }
    }
}

extension KeyCredentialProvider: ASAuthorizationControllerDelegate {
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            registrationContinuation?.resume(returning: credential)
            registrationContinuation = nil
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            assertionContinuation?.resume(returning: credential)
            assertionContinuation = nil
        } else {
            Logger().warning("Apple Authorization: Other auth case triggered, such as 'sign in with apple'")
        }
        isRunning = false

        Logger().info("Apple Authorization: Complete")
    }

    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        if (error as? ASAuthorizationError)?.code == .canceled {
            Logger().info("Apple Authorization: Ongoing authorization was cancelled")
            registrationContinuation?.resume(throwing: PasswordlessClientError.authorizationCancelled)
            assertionContinuation?.resume(throwing: PasswordlessClientError.authorizationCancelled)
            cancelContinuation?.resume()
            registrationContinuation = nil
            assertionContinuation = nil
            cancelContinuation = nil
        } else {
            Logger().error("\(error)")
            registrationContinuation?.resume(throwing: PasswordlessClientError.authorizationError(error))
            assertionContinuation?.resume(throwing: PasswordlessClientError.authorizationError(error))
            registrationContinuation = nil
            assertionContinuation = nil
        }
        isRunning = false
    }
}

extension KeyCredentialProvider: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
