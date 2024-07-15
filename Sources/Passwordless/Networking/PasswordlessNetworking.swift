import Foundation

/// A protocol to allow custom configurations of the networking layer.
///
public protocol PasswordlessNetworking {
    /// The URLSession object used to make the network requests.
    var urlSession: URLSession { get }

    /// Exposes a way to intercept the request before it gets sent and modify it's contents.
    ///
    /// - Parameter request: The request that was created that is about to be sent.
    /// 
    /// - Returns: A URLRequest that will be sent.
    ///
    func on(request: URLRequest) -> URLRequest
}

/// The default implementation of the networking layer.
///
public class DefaultPasswordlessNetworking: PasswordlessNetworking {
    public var urlSession: URLSession = URLSession.shared

    public init() {}

    public func on(request: URLRequest) -> URLRequest {
        return request
    }
}
