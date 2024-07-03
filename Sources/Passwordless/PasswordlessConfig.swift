import Foundation

public struct PasswordlessConfig {
    public let apiUrl: String
    public let apiKey: String
    public let rpId: String
    public let origin: String

    public init(
        apiUrl: String,
        apiKey: String,
        rpId: String,
        origin: String
    ) {
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.rpId = rpId
        self.origin = origin
    }
}
