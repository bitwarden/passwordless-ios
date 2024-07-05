import Foundation

// MARK: RegisterBeginResponse

/// Model used for body of the `/register/begin` response.
///
struct RegisterBeginResponse: Decodable {
    let data: CredentialCreateOptions
    let session: String
}

struct CredentialCreateOptions: Decodable {
    let challenge: String
    let user: Fido2User
}

struct Fido2User: Decodable {
    let id: String
    let name: String
}
