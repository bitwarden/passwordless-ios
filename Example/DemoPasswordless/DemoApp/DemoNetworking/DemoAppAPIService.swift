import Foundation

class DemoAppAPIService {
    let demoApiUrl: String

    init(demoApiUrl: String) {
        self.demoApiUrl = demoApiUrl
    }

    private func make<T: Decodable>(request: URLRequest) async -> T {
        var updatedRequest = request
        updatedRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let response = try! await URLSession.shared.data(for: updatedRequest)
        print(String(data: response.0, encoding: .utf8) ?? "Empty response")
        print(response)
        return try! JSONDecoder().decode(T.self, from: response.0)
    }

    func register(username: String) async -> DemoRegisterResponseModel {
        let url = URL(string: "\(demoApiUrl)/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DemoRegisterRequestModel(username: username))
        return await make(request: request)
    }

    func login(verifyToken: String) async -> DemoLoginResponseModel {
        let url = URL(string: "\(demoApiUrl)/auth/login")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(DemoLoginRequestModel(token: verifyToken))
        return await make(request: request)
    }

    func fetchCredentials(userId: String) async -> [DemoCredentialsResponseModel] {
        let url = URL(string: "\(demoApiUrl)/users/\(userId)/credentials")!
        return await make(request: URLRequest(url: url))
    }
}
