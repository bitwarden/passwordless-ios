import Foundation

struct RegisterBeginRequest: Encodable {
    let token: String
    let rpId: String
    let origin: String
}
