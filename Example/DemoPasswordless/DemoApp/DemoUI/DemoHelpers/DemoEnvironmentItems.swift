import Foundation

class DemoEnvironmentItems: ObservableObject {
    @Published var authToken: String?
    @Published var userId: String?
    @Published var showLoader = false
    let services = DemoServices()
}
