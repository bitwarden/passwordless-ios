import Foundation

// MARK: SignInCompleteResponse

/// Model used for body of the `/signin/complete` response.
///
struct SignInCompleteResponse: Decodable {
    let token: String
}
