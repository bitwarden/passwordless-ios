import SwiftUI

@main
struct DemoApp: App {
    @StateObject private var environmentItems = DemoEnvironmentItems()

    var body: some Scene {
        WindowGroup {
            Group {
                if environmentItems.authToken != nil {
                    NavigationStack {
                        DemoUserCredentialsView()
                    }
                } else {
                    NavigationStack {
                        DemoSignInView()
                    }
                }
            }
            .environmentObject(environmentItems)
            .overlay {
                if environmentItems.showLoader {
                    DemoLoader()
                }
            }
        }
    }
}
