import Foundation

// MARK: SignInBeginRequest

/// Model used for body of the `/signin/begin` request.
///
struct SignInBeginRequest: Encodable {
    let userId: String?
    let alias: String?
    let rpId: String
    let origin: String
}
