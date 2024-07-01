import Foundation

struct SignInBeginResponse: Decodable {
    let data: AssertionOptions
    let session: String
}

struct AssertionOptions: Decodable {
    let challenge: String
    let allowCredentials: [PublicKeyCredentialDescriptor]
    let userVerification: UserVerificationRequirement
}

struct PublicKeyCredentialDescriptor: Decodable {
    let type: String
    let id: Int
    let transports: [AuthenticatorTransport]?
}

enum AuthenticatorTransport: String, Codable {
    case usb, nfc, ble, hybrid, `internal`
    case smartcard = "smart-card"
}

enum UserVerificationRequirement: String, Decodable {
    case required, preferred, discouraged
}
