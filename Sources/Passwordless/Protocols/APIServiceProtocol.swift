import Foundation

// MARK: APIServiceProtocol

/// Protocol that defines the items needed to register and sign in within an APIService.
///
protocol APIServiceProtocol {
    /// Makes a call to begin registration.
    ///
    /// - Parameter token: A token provided from the relying party backend.
    ///
    /// - Returns: A response model containing challenge data for the user.
    ///
    func registerBegin(token: String) async throws -> RegisterBeginResponse

    /// Makes a call to complete registration.
    ///
    /// - Parameter requestModel: An object that provides the resulting information from the Apple authorization steps.
    ///
    /// - Returns: A response model containing results from the challenge request.
    ///
    func registerComplete(requestModel: RegisterCompleteRequest) async throws -> RegisterCompleteResponse

    /// Makes a call to begin sign in. Providing no alias will put the Apple authorization in auto fill mode.
    ///
    /// - Parameters:
    ///    - alias: An alias for the the user (aka username).
    ///    - userId: The raw user Id.
    ///
    /// - Returns: A response model containing challenge data for the user.
    ///
    func signInBegin(alias: String?, userId: String?) async throws -> SignInBeginResponse

    /// Makes a call to complete sign in.
    ///
    /// - Parameter requestModel: An object that provides the resulting information from the Apple authorization steps.
    ///
    /// - Returns: A response model containing results from the challenge request.
    ///
    func signInComplete(requestModel: SignInCompleteRequest) async throws -> SignInCompleteResponse
}

// MARK: Default implementations

extension APIServiceProtocol {
    /// Convenience wrapper to default userId to nil.
    ///
    /// - Parameter alias: An alias for the the user (aka username).
    ///
    /// - Returns: A response model containing challenge data for the user.
    ///
    func signInBegin(alias: String?) async throws -> SignInBeginResponse {
        try await signInBegin(alias: alias, userId: nil)
    }
}
