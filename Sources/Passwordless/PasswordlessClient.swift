import Foundation
import AuthenticationServices

// MARK: PasswordlessClient

/// A Passwordless client that helps in managing Passkey credentials between a relying party and the local user on an iOS device.
///
public class PasswordlessClient {
    /// The configuration needed to initialize a PasswordlessClient.
    private let config: PasswordlessConfig

    /// The api service used to make network calls to the API.
    private let apiService: APIServiceProtocol

    /// The provider responsible for interfacing with the local user's device credentials.
    private let keyProvider: KeyCredentialProviderProtocol

    /// Initializes a new PasswordlessClient.
    ///
    /// - Parameter config: The configuration needed to initialize a PasswordlessClient.
    ///
    public init(config: PasswordlessConfig) {
        self.config = config
        apiService = APIService(config: config)
        keyProvider = KeyCredentialProvider(rpId: config.rpId)
    }

    /// Initializes a new PasswordlessClient. Internal initializer used for injection when testing.
    ///
    /// - Parameters:
    ///    - config: The configuration needed to initialize a PasswordlessClient.
    ///    - apiService: The api service used to make network calls to the API.
    ///    - keyProvider: The provider responsible for interfacing with the local user's device credentials.
    ///
    init (
        config: PasswordlessConfig,
        apiService: APIServiceProtocol,
        keyProvider: KeyCredentialProviderProtocol
    ) {
        self.config = config
        self.apiService = apiService
        self.keyProvider = keyProvider
    }

    /// Asks Passwordless client to go through the Pass Key registration process to add a new user.
    ///
    /// - Parameter token: A token provided from the relying party backend.
    ///
    /// - Returns: A token that can be verified by the relying party backend.
    ///
    public func register(token: String) async throws -> String {
        let registerResponse = try await apiService.registerBegin(token: token)

        let response = try await keyProvider.requestAuthorization(registerResponse: registerResponse)

        let request = RegisterCompleteRequest(
            session: registerResponse.session,
            response: response,
            origin: config.origin,
            rpId: config.rpId,
            nickname: nil
        )

        let completeResponse = try await apiService.registerComplete(requestModel: request)
        return completeResponse.token
    }


    /// Asks Passwordless client to go through the Pass Key registration process to sign in an user. Providing no alias will put the
    /// Apple authorization into auto fill mode (AKA quick action from the virtual keyboard). Apple recommends you run autofill mode
    /// as soon as a sign in field is presented. This allows the keyboard to have enough time to warm up with results by the time it is
    /// shown to a user.
    ///
    /// - Parameter alias: An optional username to trigger the authorization.
    ///
    /// - Returns: A token that can be verified by the relying party backend.
    ///
    public func signIn(alias: String? = nil) async throws -> String {
        let signInResponse = try await apiService.signInBegin(alias: alias)

        let response = try await keyProvider.requestAssertion(
            signInResponse: signInResponse,
            autoFill: alias == nil
        )

        let request = SignInCompleteRequest(
            session: signInResponse.session,
            response: response,
            origin: config.origin,
            rpId: config.rpId
        )

        let completeResponse = try await apiService.signInComplete(requestModel: request)
        return completeResponse.token
    }

    /// Cancels an existing request. Mostly used to cancel sign in with autofill enabled.
    ///
    public func cancelExistingRequests() async {
        await keyProvider.cancelExistingRequest()
    }
}
