import Foundation

// MARK: RegisterBeginRequest

/// Model used for body of the `/register/begin` request.
///
struct RegisterBeginRequest: Encodable {
    let token: String
    let rpId: String
    let origin: String
}
