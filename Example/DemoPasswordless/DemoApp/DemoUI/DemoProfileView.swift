import SwiftUI

struct DemoProfileView: View {
    @EnvironmentObject var environment: DemoEnvironmentItems

    var body: some View {
        DemoWebView(url: URL(string: "https://demo.passwordless.dev/profile?token=\(environment.authToken ?? "")")!)
            .navigationStyle("Profile")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Sign Out") {
                        environment.authToken = nil
                    }
                    .tint(.red)
                    .buttonStyle(.borderedProminent)
                }
            }
    }
}
