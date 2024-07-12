import Foundation
import OSLog

// MARK: APIService

/// The API Service that communicates with the backend.
///
class APIService {
    /// The configuration items needed to make API requests.
    private let config: PasswordlessConfig

    /// The URLSession object used to make the network requests. 
    private let urlSession: URLSession

    /// Initializes an APIService.
    ///
    /// - Parameters:
    ///    - config: The configuration items needed to make API requests.
    ///    - urlSession: The URLSession object used to make the network requests. Defaults to shared.
    ///    Used for injection for testing purposes.
    ///
    init(
        config: PasswordlessConfig,
        urlSession: URLSession = URLSession.shared
    ) {
        self.config = config
        self.urlSession = urlSession
    }
}

// MARK: APIServiceProtocol

/// Protocol that defines the items needed to register and sign in within an APIService.
///
extension APIService: APIServiceProtocol {
    /// Makes a call to begin registration.
    ///
    /// - Parameter token: A token provided from the relying party backend.
    ///
    /// - Returns: A response model containing challenge data for the user.
    ///
    func registerBegin(token: String) async throws -> RegisterBeginResponse {
        let request = try buildRequest(
            path: "/register/begin",
            method: "POST",
            body: RegisterBeginRequest(token: token, rpId: config.rpId, origin: config.origin)
        )
        return try await make(request: request)
    }

    /// Makes a call to complete registration.
    ///
    /// - Parameter requestModel: An object that provides the resulting information from the Apple authorization steps.
    ///
    /// - Returns: A response model containing results from the challenge request.
    ///
    func registerComplete(requestModel: RegisterCompleteRequest) async throws -> RegisterCompleteResponse {
        let request = try buildRequest(
            path: "/register/complete",
            method: "POST",
            body: requestModel
        )
        return try await make(request: request)
    }

    /// Makes a call to begin sign in. Providing no alias will put the Apple authorization in auto fill mode.
    ///
    /// - Parameters:
    ///    - alias: An alias for the the user (aka username).
    ///    - userId: The raw user Id.
    ///
    /// - Returns: A response model containing challenge data for the user.
    ///
    func signInBegin(alias: String? = nil, userId: String? = nil) async throws -> SignInBeginResponse {
        let request = try buildRequest(
            path: "/signin/begin",
            method: "POST",
            body: SignInBeginRequest(userId: userId, alias: alias, rpId: config.rpId, origin: config.origin)
        )
        return try await make(request: request)
    }

    /// Makes a call to complete sign in.
    ///
    /// - Parameter requestModel: An object that provides the resulting information from the Apple authorization steps.
    ///
    /// - Returns: A response model containing results from the challenge request.
    ///
    func signInComplete(requestModel: SignInCompleteRequest) async throws -> SignInCompleteResponse {
        let request = try buildRequest(
            path: "/signin/complete",
            body: requestModel
        )
        return try await make(request: request)
    }
}

// MARK: Private helpers

extension APIService{
    /// Creates a URLRequest.
    ///
    /// - Parameters:
    ///    - path: The path to append to the end of the apiUrl provided in the config.
    ///    - method: The request method. Defaults to GET.
    ///    - body: The encodable object to put into the request body.
    ///
    /// - Returns: A response model containing challenge data for the user.
    ///
    private func buildRequest(
        path: String,
        method: String = "GET",
        body: Encodable
    ) throws -> URLRequest {
        guard let url = URL(string: "\(config.apiUrl)\(path)") else {
            throw PasswordlessClientError.internalErrorInvalidURL("\(config.apiUrl)\(path)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    /// Make the authorized http request and return the response object for the given return type.
    ///
    /// - Parameter request: The URLRequest to make.
    ///
    /// - Returns: The response object decoded from the response body json.
    ///
    private func make<T: Decodable>(request: URLRequest) async throws -> T {
        var updatedRequest = request
        updatedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        updatedRequest.setValue(config.apiKey, forHTTPHeaderField: "Apikey")

        let data: Data
        let dataString: String
        var httpResponse: HTTPURLResponse?
        do {
            let response = try await urlSession.data(for: updatedRequest)
            data = response.0
            dataString = String(data: data, encoding: .utf8) ?? "Empty response"
            httpResponse = response.1 as? HTTPURLResponse
            
            Logger().info("Status Code: \(httpResponse?.statusCode ?? 0), Body: \(dataString)")
        } catch {
            throw PasswordlessClientError.internalErrorNetworkRequestFailed(error)
        }
        guard let httpResponse, httpResponse.statusCode < 400 else {
            let errorResponse = try? JSONDecoder().decode(PasswordlessErrorResponse.self, from: data)
            throw PasswordlessClientError.internalErrorNetworkRequestResponseError(
                httpResponse?.statusCode,
                errorResponse
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PasswordlessClientError.internalErrorDecodingJson(error)
        }
    }
}
