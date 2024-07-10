import Foundation

// MARK: RegisterCompleteResponse

/// Model used for body of the `/register/complete` response.
///
struct RegisterCompleteResponse: Decodable {
    let token: String
}
