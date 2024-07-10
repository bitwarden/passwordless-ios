import Foundation
@testable import Passwordless

class MockAPIService: APIServiceProtocol {
    var calledRegisterBegin = false
    var calledRegisterComplete = false
    var calledSignInBegin = false
    var calledSignInComplete = false

    func registerBegin(token: String) async throws -> RegisterBeginResponse {
        calledRegisterBegin = true

        return RegisterBeginResponse(
            data: CredentialCreateOptions(challenge: "", user: Fido2User(id: "", name: "")),
            session: ""
        )
    }

    func registerComplete(requestModel: RegisterCompleteRequest) async throws -> RegisterCompleteResponse {
        calledRegisterComplete = true
        return RegisterCompleteResponse(token: "")
    }

    func signInBegin(alias: String?, userId: String?) async throws -> SignInBeginResponse {
        calledSignInBegin = true
        return SignInBeginResponse(
            data: AssertionOptions(challenge: "", allowCredentials: [], userVerification: .preferred),
            session: ""
        )
    }

    func signInComplete(requestModel: SignInCompleteRequest) async throws -> SignInCompleteResponse {
        calledSignInComplete = true
        return SignInCompleteResponse(token: "")
    }
}
