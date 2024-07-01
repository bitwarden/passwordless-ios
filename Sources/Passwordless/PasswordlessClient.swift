import Foundation
import AuthenticationServices

public class PasswordlessClient {
    private let apiUrl: String
    private let apiKey: String
    private let rpId: String
    private let origin: String
    private let relyingPartyIdentifier: String
    private let apiService: PasswordlessAPIService
    private let keyProvider: KeyCredentialProvider

    public init(
        apiUrl: String,
        apiKey: String,
        rpId: String,
        origin: String,
        relyingPartyIdentifier: String
    ) {
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.rpId = rpId
        self.origin = origin
        self.relyingPartyIdentifier = relyingPartyIdentifier

        apiService = PasswordlessAPIService(
            apiUrl: apiUrl,
            apiKey: apiKey,
            rpId: rpId,
            origin: origin
        )

        keyProvider = KeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)
    }

    public func register(token: String) async throws -> String {
        let registerResponse = try await apiService.registerBegin(token: token)

        let credential = try await keyProvider.requestAuthorization(registerResponse: registerResponse)

        let request = RegisterCompleteRequest(
            session: registerResponse.session,
            response: AttestationRawResponse(credential: credential),
            origin: origin,
            rpId: rpId,
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
            origin: origin,
            rpId: rpId
        )
        return try await apiService.signInComplete(requestModel: request).token
    }

    public func cancelExistingRequests() async {
        await keyProvider.cancelExistingRequest()
    }
}
