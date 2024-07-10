import AuthenticationServices
import Foundation
import OSLog

// MARK: KeyCredentialProvider

/// The key credential provider that utilizes an authorization controller to aid in registration and sign in
/// validation of the local iOS user.
/// 
class KeyCredentialProvider: NSObject  {
    /// The relying party identifier.
    private let rpId: String

    /// A wrapper object that manages an ASAuthenticationController.
    private var authControllerWrapper: ASAuthorizationControllerWrapperProtocol

    /// Whether or not an authorization session is currently in progress.
    private var isRunning = false

    /// Registration continuation property to flatten the delegation from the authControllerWrapper.
    private var registrationContinuation: CheckedContinuation<AttestationRawResponse, Error>?

    /// Assertion continuation property to flatten the delegation from the authControllerWrapper.
    private var assertionContinuation: CheckedContinuation<AssertionRawResponse, Error>?

    /// Cancel continuation property to flatten the delegation from the authControllerWrapper.
    private var cancelContinuation: CheckedContinuation<Void, Never>?

    /// Initializes a KeyCredentialProvider.
    ///
    /// - Parameters:
    ///    - rpId: The relying party identifier.
    ///    - authControllerWrapper: A wrapper object that allows for injection of the
    ///    ASAuthenticationController. Defaults to the real Apple controller.
    ///
    init(
        rpId: String,
        authControllerWrapper: ASAuthorizationControllerWrapperProtocol = ASAuthorizationControllerWrapper()
    ) {
        self.rpId = rpId
        self.authControllerWrapper = authControllerWrapper

        super.init()
        self.authControllerWrapper.delegate = self
    }
}

// MARK: KeyCredentialProviderProtocol

/// Protocol that defines a key credential provider.
///
extension KeyCredentialProvider: KeyCredentialProviderProtocol {
    /// Request an authorization response from the key credential provider.
    ///
    /// - Parameter registerResponse: Object provided by relying party identifier containing challenge information.
    ///
    /// - Returns: The attestation result from the authorization request.
    ///
    func requestAuthorization(registerResponse: RegisterBeginResponse) async throws -> AttestationRawResponse {
        await cancelExistingRequest()

        Logger().info("Apple Authorization for registration is running")

        guard let challenge = registerResponse.data.challenge.base64URLDecodedData() else {
            throw PasswordlessClientError.internalErrorUnableToDecodeChallenge
        }
        guard let userId = registerResponse.data.user.id.data(using: .utf8) else {
            throw PasswordlessClientError.internalErrorUnableToEncodeUserId
        }
        let name = registerResponse.data.user.name

        authControllerWrapper.createControllerForRegistration(
            rpId: rpId,
            challenge: challenge,
            name: name,
            userId: userId
        )

        return try await withCheckedThrowingContinuation { continuation in
            isRunning = true
            registrationContinuation = continuation
            authControllerWrapper.performRequests()
        }
    }

    /// Request an assertion response from the key credential provider.
    ///
    /// - Parameters:
    ///    - signInResponse: Object provided by relying party identifier containing challenge information.
    ///    - autoFill: Whether or not the request should use auto fill mode.
    ///
    /// - Returns: The assertion result from the authorization request.
    ///
    func requestAssertion(
        signInResponse: SignInBeginResponse,
        autoFill: Bool
    ) async throws -> AssertionRawResponse {
        await cancelExistingRequest()

        Logger().info("Apple Assertion for sign in running(autofill: \(autoFill))")

        guard let challenge = signInResponse.data.challenge.base64URLDecodedData() else {
            throw PasswordlessClientError.internalErrorUnableToDecodeChallenge
        }

        authControllerWrapper.createControllerForAssertion(
            rpId: rpId,
            challenge: challenge
        )

        return try await withCheckedThrowingContinuation { continuation in
            isRunning = true
            assertionContinuation = continuation
            if autoFill {
                authControllerWrapper.performAutoFillAssistedRequests()
            } else {
                authControllerWrapper.performRequests()
            }
        }
    }

    /// Cancels the authorization process for the key credential provider.
    ///
    func cancelExistingRequest() async {
        if isRunning {
            await withCheckedContinuation { continuation in
                cancelContinuation = continuation
                authControllerWrapper.cancel()
            }
        }
    }
}

// MARK: AuthorizationControllerWrapperDelegate

/// Delegate that defines responses from the Apple authorization controller.
///
extension KeyCredentialProvider: AuthorizationControllerWrapperDelegate {
    /// The Apple authorization controller completed the registration steps.
    ///
    /// - Parameter attestation: The object containing the resulting information about the Apple authorization.
    ///
    func didCompleteWithRegistration(attestation: AttestationRawResponse) {
        isRunning = false
        registrationContinuation?.resume(returning: attestation)
        registrationContinuation = nil

        Logger().info("Apple Authorization: Complete")
    }
    
    /// The Apple authorization controller completed the sign in/assertion steps.
    ///
    /// - Parameter assertion: The object containing the resulting information about the Apple authorization.
    ///
    func didCompleteWithAssertion(assertion: AssertionRawResponse) {
        isRunning = false
        assertionContinuation?.resume(returning: assertion)
        assertionContinuation = nil

        Logger().info("Apple Authorization: Complete")
    }
    
    /// The Apple authorization controller completed with an error.
    ///
    /// - Parameter error: The error that occurred during the Apple authorization.
    ///
    func didCompleteWithError(error: Error) {
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
