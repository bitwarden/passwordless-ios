import AuthenticationServices
import Foundation

struct SignInCompleteRequest: Encodable {
    let session: String
    let response: AssertionRawResponse
    let origin: String
    let rpId: String
}

struct AssertionRawResponse: Encodable {
    let id: String
    let rawId: String
    let type: String
    let response: AssertionResponse
    let extensions: [String : String]?

    init(credential: ASAuthorizationPlatformPublicKeyCredentialAssertion) {
        id = credential.credentialID.base64URLEncodedString()
        rawId = credential.credentialID.base64URLEncodedString()
        type = "public-key"
        response = AssertionResponse(
            authenticatorData: credential.rawAuthenticatorData.base64URLEncodedString(),
            clientDataJSON: credential.rawClientDataJSON.base64URLEncodedString(),
            signature: credential.signature.base64URLEncodedString()
        )
        extensions = [:]
    }
}

struct AssertionResponse: Encodable {
    let authenticatorData: String
    let clientDataJSON: String
    let signature: String
}
