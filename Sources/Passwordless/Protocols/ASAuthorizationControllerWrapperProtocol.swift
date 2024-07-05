import Foundation

// MARK: ASAuthorizationControllerWrapperProtocol

/// Protocol that defines the items needed to interface with the Apple authorization controller.
///
protocol ASAuthorizationControllerWrapperProtocol {
    /// The delegate that returns the result of the Apple authorization request.
    var delegate: AuthorizationControllerWrapperDelegate? { get set }

    /// Creates an Apple authorization controller setup with an assertion/sign in request.
    ///
    /// - Parameters:
    ///    - rpId: The relying party identifier.
    ///    - challenge: The challenge provided by the relying party.
    ///
    func createControllerForAssertion(
        rpId: String,
        challenge: Data
    )

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
    )

    /// Begins the authorization process for the Apple authorization controller.
    ///
    func performRequests()

    /// Begins the autofill authorization process for the Apple authorization controller.
    ///
    func performAutoFillAssistedRequests()

    /// Cancels the authorization process for the Apple authorization controller.
    ///
    func cancel()
}

// MARK: AuthorizationControllerWrapperDelegate

/// Delegate that defines responses from the Apple authorization controller.
///
protocol AuthorizationControllerWrapperDelegate: AnyObject {
    /// The Apple authorization controller completed the registration steps.
    ///
    /// - Parameter attestation: The object containing the resulting information about the Apple authorization.
    ///
    func didCompleteWithRegistration(attestation: AttestationRawResponse)

    /// The Apple authorization controller completed the sign in/assertion steps.
    ///
    /// - Parameter assertion: The object containing the resulting information about the Apple authorization.
    ///
    func didCompleteWithAssertion(assertion: AssertionRawResponse)

    /// The Apple authorization controller completed with an error.
    ///
    /// - Parameter error: The error that occurred during the Apple authorization.
    ///
    func didCompleteWithError(error: Error)
}
