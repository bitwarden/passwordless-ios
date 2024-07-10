import Foundation

/// Data extensions to clean up base 64 URL encoding.
/// 
extension Data {
    func base64URLEncodedString() -> String {
        self
            .base64EncodedString()
            .base64URLEncodedString()
    }
}
