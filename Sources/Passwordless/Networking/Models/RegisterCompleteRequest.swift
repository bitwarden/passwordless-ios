import AuthenticationServices
import Foundation

// MARK: RegisterCompleteRequest

/// Model used for body of the `/register/complete` request.
///
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

    init(
        credentialID: Data,
        rawAttestationObject: Data?,
        rawClientDataJSON: Data
    ) {
        id = credentialID.base64URLEncodedString()
        rawId = credentialID.base64URLEncodedString()
        type = "public-key"
        response = AttestationResponse(
            attestationObject: rawAttestationObject?.base64URLEncodedString(),
            clientDataJSON: rawClientDataJSON.base64URLEncodedString(),
            transports: nil
        )
        extensions = [:]
    }
}

struct AttestationResponse: Encodable {
    let attestationObject: String?
    let clientDataJSON: String
    let transports: [AuthenticatorTransport]?
}
