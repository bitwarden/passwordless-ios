import Foundation
@testable import Passwordless

public class MockPasswordlessNetworking: PasswordlessNetworking {
    public var urlSession: URLSession

    public init(urlSession: URLSession) {
        self.urlSession = urlSession
    }

    public func on(request: URLRequest) -> URLRequest {
        return request
    }
}
