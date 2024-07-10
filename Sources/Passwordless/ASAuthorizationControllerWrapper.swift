import AuthenticationServices
import Foundation

// MARK: ASAuthorizationControllerWrapper

/// ASAuthorizationControllerWrapper is a class that wraps the functionality provided in the ASAuthorizationController object. This is needed
/// aid with unit testing so we can provide a mock version of the ASAuthorizationController that does not connect to real OS calls. This
/// class should not be tested as it is only a means to avoid the real OS interactions. It should only contain the minimal amount of code
/// needed to interface with the ASAuthorizationController
///
class ASAuthorizationControllerWrapper: NSObject, ASAuthorizationControllerWrapperProtocol {
    /// The delegate that returns the result of the Apple authorization request.
    weak var delegate: AuthorizationControllerWrapperDelegate?

    /// The ASAuthorizationController we are wrapping.
    private var authController: ASAuthorizationController?

    /// Creates an Apple authorization controller setup with an assertion/sign in request.
    ///
    /// - Parameters:
    ///    - rpId: The relying party identifier.
    ///    - challenge: The challenge provided by the relying party.
    ///
    func createControllerForAssertion(
        rpId: String,
        challenge: Data
    ) {
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let platformKeyRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)
        authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController?.delegate = self
        authController?.presentationContextProvider = self
    }

    /// Creates an Apple authorization controller setup with an registration request.
    ///
    /// - Parameters:
    ///    - rpId: The relying party identifier.
    ///    - challenge: The challenge provided by the relying party.
    ///    - name: The user name.
    ///    - userId: The user Id provided by the relying party.
    ///
    func createControllerForRegistration(
        rpId: String,
        challenge: Data,
        name: String,
        userId: Data
    ) {
        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: rpId)
        let platformKeyRequest = platformProvider.createCredentialRegistrationRequest(challenge: challenge, name: name, userID: userId)
        authController = ASAuthorizationController(authorizationRequests: [platformKeyRequest])
        authController?.delegate = self
        authController?.presentationContextProvider = self
    }

    /// Begins the authorization process for the Apple authorization controller.
    ///
    func performRequests() {
        authController?.performRequests()
    }

    /// Begins the autofill authorization process for the Apple authorization controller.
    ///
    func performAutoFillAssistedRequests() {
        authController?.performAutoFillAssistedRequests()
    }

    /// Cancels the authorization process for the Apple authorization controller.
    ///
    func cancel() {
        authController?.cancel()
    }
}

// MARK: ASAuthorizationControllerDelegate

/// Required delegate implementation to handle registration responses.
///
extension ASAuthorizationControllerWrapper: ASAuthorizationControllerDelegate {
    /// Delegate function that handles success scenarios.
    ///
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithAuthorization authorization: ASAuthorization
    ) {
        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            let attestation = AttestationRawResponse(
                credentialID: credential.credentialID,
                rawAttestationObject: credential.rawAttestationObject,
                rawClientDataJSON: credential.rawClientDataJSON
            )
            delegate?.didCompleteWithRegistration(attestation: attestation)
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            let assertion = AssertionRawResponse(
                credentialID: credential.credentialID,
                rawAuthenticatorData: credential.rawAuthenticatorData,
                rawClientDataJSON: credential.rawClientDataJSON,
                signature: credential.signature
            )
            delegate?.didCompleteWithAssertion(assertion: assertion)
        }
    }

    /// Delegate function that handles error scenarios.
    ///
    func authorizationController(
        controller: ASAuthorizationController,
        didCompleteWithError error: Error
    ) {
        delegate?.didCompleteWithError(error: error)
    }
}

// MARK: ASAuthorizationControllerPresentationContextProviding

/// Required delegate implementation to set the PresentationAnchor for the given controller.
///
extension ASAuthorizationControllerWrapper: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        ASPresentationAnchor()
    }
}
