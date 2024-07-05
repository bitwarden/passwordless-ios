import AuthenticationServices
import Foundation

// MARK: SignInCompleteRequest

/// Model used for body of the `/signin/complete` request.
///
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

    init(
        credentialID: Data,
        rawAuthenticatorData: Data,
        rawClientDataJSON: Data,
        signature: Data
    ) {
        id = credentialID.base64URLEncodedString()
        rawId = credentialID.base64URLEncodedString()
        type = "public-key"
        response = AssertionResponse(
            authenticatorData: rawAuthenticatorData.base64URLEncodedString(),
            clientDataJSON: rawClientDataJSON.base64URLEncodedString(),
            signature: signature.base64URLEncodedString()
        )
        extensions = [:]
    }
}

struct AssertionResponse: Encodable {
    let authenticatorData: String
    let clientDataJSON: String
    let signature: String
}
