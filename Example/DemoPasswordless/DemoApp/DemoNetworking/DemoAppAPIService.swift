import Foundation

class DemoAppAPIService {
    let demoApiUrl: String

    init(demoApiUrl: String) {
        self.demoApiUrl = demoApiUrl
    }

    private func make<T: Decodable>(request: URLRequest, authToken: String? = nil) async -> T {
        var updatedRequest = request
        updatedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        if let authToken {
            updatedRequest.setValue("Bearer \(authToken)", forHTTPHeaderField: "Authorization")
        }

        let response = try! await URLSession.shared.data(for: updatedRequest)
        let data = response.0
        let dataString = String(data: data, encoding: .utf8) ?? "Empty response"
        let httpResponse = response.1 as! HTTPURLResponse

        print("Status Code: \(httpResponse.statusCode), Body: \(dataString)")
        return try! JSONDecoder().decode(T.self, from: data)
    }

    func register(username: String, firstName: String, lastName: String) async -> DemoRegisterResponse {
        let url = URL(string: "\(demoApiUrl)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(
            DemoRegisterRequest(
                username: username,
                firstName: firstName,
                lastName: lastName
            )
        )
        return await make(request: request)
    }

    func login(verifyToken: String) async -> DemoLoginResponse {
        let url = URL(string: "\(demoApiUrl)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DemoLoginRequest(token: verifyToken))
        return await make(request: request)
    }

    func fetchCredentials(userId: String, authToken: String) async -> [DemoCredentialsResponse] {
        let url = URL(string: "\(demoApiUrl)/users/\(userId)/credentials")!
        return await make(request: URLRequest(url: url), authToken: authToken)
    }
}
