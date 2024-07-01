import AuthenticationServices
import Foundation

struct RegisterCompleteRequest: Encodable {
    let session: String
    let response: AttestationRawResponse
    let origin: String
    let rpId: String
    let nickname: String?
}

struct AttestationRawResponse: Encodable {
    let id: String
    let rawId: String
    let type: String
    let response: AttestationResponse
    let extensions: [String: [String: Bool]]

    init(credential: ASAuthorizationPlatformPublicKeyCredentialRegistration) {
        id = credential.credentialID.base64URLEncodedString()
        rawId = credential.credentialID.base64URLEncodedString()
        type = "public-key"
        response = AttestationResponse(
            attestationObject: credential.rawAttestationObject?.base64URLEncodedString(),
            clientDataJSON: credential.rawClientDataJSON.base64URLEncodedString(),
            transports: nil
        )
        // hardcoded for now to get the API to work, but there's a fix going
        // into the server to allow this to be optional.
        extensions = ["credProps": ["rk": true ]]
    }
}

struct AttestationResponse: Encodable {
    let attestationObject: String?
    let clientDataJSON: String
    let transports: [AuthenticatorTransport]?
}
