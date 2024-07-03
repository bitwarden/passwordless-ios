import Foundation
import AuthenticationServices

public class PasswordlessClient {
    private let config: PasswordlessConfig
    private let apiService: PasswordlessAPIService
    private let keyProvider: KeyCredentialProvider

    public init(config: PasswordlessConfig) {
        self.config = config
        apiService = PasswordlessAPIService(config: config)
        keyProvider = KeyCredentialProvider(relyingPartyIdentifier: config.rpId)
    }

    public func register(token: String) async throws -> String {
        let registerResponse = try await apiService.registerBegin(token: token)

        let credential = try await keyProvider.requestAuthorization(registerResponse: registerResponse)

        let request = RegisterCompleteRequest(
            session: registerResponse.session,
            response: AttestationRawResponse(credential: credential),
            origin: config.origin,
            rpId: config.rpId,
            nickname: nil
        )
        return (try await apiService.registerComplete(requestModel: request)).token
    }

    public func signIn(alias: String? = nil) async throws -> String {
        let signInResponse = try await apiService.signInBegin(alias: alias)

        let credential = try await keyProvider.requestAssertion(
            signInResponse: signInResponse,
            autoFill: alias == nil
        )

        let request = SignInCompleteRequest(
            session: signInResponse.session,
            response: AssertionRawResponse(credential: credential),
            origin: config.origin,
            rpId: config.rpId
        )
        return try await apiService.signInComplete(requestModel: request).token
    }

    public func cancelExistingRequests() async {
        await keyProvider.cancelExistingRequest()
    }
}
