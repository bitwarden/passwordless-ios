import Foundation

extension Data {
    func base64URLEncodedString() -> String {
        self
            .base64EncodedString()
            .base64URLEncodedString()
    }
}
