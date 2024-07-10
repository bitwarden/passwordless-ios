import AuthenticationServices
import Foundation

// MARK: KeyCredentialProviderProtocol

/// Protocol that defines a key credential provider.
///
protocol KeyCredentialProviderProtocol {
    /// Request an authorization response from the key credential provider.
    ///
    /// - Parameter registerResponse: Object provided by relying party identifier containing challenge information.
    ///
    /// - Returns: The attestation result from the authorization request.
    ///
    func requestAuthorization(registerResponse: RegisterBeginResponse) async throws -> AttestationRawResponse

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
    ) async throws -> AssertionRawResponse

    /// Cancels the authorization process for the key credential provider.
    ///
    func cancelExistingRequest() async
}
