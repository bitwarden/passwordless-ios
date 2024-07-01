import Foundation
import OSLog

class PasswordlessAPIService {
    private let apiUrl: String
    private let apiKey: String
    private let rpId: String
    private let origin: String
    private let urlSession: URLSession

    init(
        apiUrl: String,
        apiKey: String,
        rpId: String,
        origin: String,
        urlSession: URLSession = URLSession.shared
    ) {
        self.apiUrl = apiUrl
        self.apiKey = apiKey
        self.rpId = rpId
        self.origin = origin
        self.urlSession = urlSession
    }

    func registerBegin(token: String) async throws -> RegisterBeginResponse {
        let request = try buildRequest(
            path: "/register/begin",
            method: "POST",
            body: RegisterBeginRequest(token: token, rpId: rpId, origin: origin)
        )
        return try await make(request: request)
    }

    func registerComplete(requestModel: RegisterCompleteRequest) async throws -> RegisterCompleteResponse {
        let request = try buildRequest(
            path: "/register/complete",
            method: "POST",
            body: requestModel
        )
        return try await make(request: request)
    }

    func signInBegin(alias: String? = nil, userId: String? = nil) async throws -> SignInBeginResponse {
        let request = try buildRequest(
            path: "/signin/begin",
            method: "POST",
            body: SignInBeginRequest(userId: userId, alias: alias, rpId: rpId, origin: origin)
        )
        return try await make(request: request)
    }

    func signInComplete(requestModel: SignInCompleteRequest) async throws -> SignInCompleteResponse {
        let request = try buildRequest(
            path: "/signin/complete",
            body: requestModel
        )
        return try await make(request: request)
    }
}

extension PasswordlessAPIService{
    private func buildRequest(
        path: String,
        method: String = "GET",
        body: Encodable
    ) throws -> URLRequest {
        guard let url = URL(string: "\(apiUrl)\(path)") else {
            throw PasswordlessClientError.internalErrorInvalidURL("\(apiUrl)\(path)")
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try JSONEncoder().encode(body)
        return request
    }

    private func make<T: Decodable>(request: URLRequest) async throws -> T {
        var updatedRequest = request
        updatedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        updatedRequest.setValue(apiKey, forHTTPHeaderField: "Apikey")

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
            throw PasswordlessClientError.internalErrorNetworkRequestResponseError(
                httpResponse?.statusCode,
                dataString
            )
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw PasswordlessClientError.internalErrorDecodingJson(error)
        }
    }
}
