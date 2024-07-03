import Foundation

struct DemoCredentialsResponse: Decodable, Identifiable {
    var id: String { publicKey }

    let publicKey: String
    let userHandle: String
    let signatureCounter: Int
    let attestationFmt: String
    let createdAt: String
    let aaGuid: String
    let lastUsedAt: String
    let rpId: String?
    let origin: String
    let country: String
    let device: String
    let nickname: String?
    let userId: String
}
