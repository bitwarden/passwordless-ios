import Foundation
@testable import Passwordless

class MockKeyCredentialProvider: KeyCredentialProviderProtocol {
    var calledRequestAuthorization = false
    var calledRequestAssertion = false
    var calledCancelExistingRequest = false

    func requestAuthorization(registerResponse: RegisterBeginResponse) async throws -> AttestationRawResponse {
        calledRequestAuthorization = true
        return AttestationRawResponse(
            credentialID: Data(),
            rawAttestationObject: nil,
            rawClientDataJSON: Data()
        )
    }

    func requestAssertion(signInResponse: SignInBeginResponse, autoFill: Bool) async throws -> AssertionRawResponse {
        calledRequestAssertion = true
        return AssertionRawResponse(
            credentialID: Data(),
            rawAuthenticatorData: Data(),
            rawClientDataJSON: Data(),
            signature: Data()
        )
    }

    func cancelExistingRequest() async {
        calledCancelExistingRequest = true
    }
}
