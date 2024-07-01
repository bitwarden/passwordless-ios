import Foundation

struct SignInBeginRequest: Encodable {
    let userId: String?
    let alias: String?
    let rpId: String
    let origin: String
}
