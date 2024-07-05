import SwiftUI

struct DemoUserCredentialsView: View {
    @EnvironmentObject var environment: DemoEnvironmentItems
    @State private var credentials: [DemoCredentialsResponse] = []

    var body: some View {
        List(credentials) { credential in
            VStack(alignment: .leading) {
                Text("**Public Key:** \(credential.publicKey)")
                Text("**Created:** \(credential.createdAt)")
                Text("**Last Used:** \(credential.lastUsedAt)")
                Text("**Device:** \(credential.device)")
                Text("**Origin:** \(credential.origin)")
                Text("**Country:** \(credential.country)")
            }
            .multilineTextAlignment(.leading)
            .font(.system(size: 9))
        }
        .listStyle(.inset)
        .navigationStyle("Credentials")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Sign Out") {
                    environment.authToken = nil
                    environment.userId = nil
                    credentials = []
                }
                .tint(.red)
                .buttonStyle(.borderedProminent)
            }
        }
        .onAppear {
            if !Preview.inPreviewMode {
                Task {
                    await fetchCredentials()
                }
            }
        }
    }
}

// MARK: Network Call

extension DemoUserCredentialsView {
    private func fetchCredentials() async {
        credentials = await environment.services.demoAPIService.fetchCredentials(
            userId: environment.userId ?? "",
            authToken: environment.authToken ?? ""
        )
        .sorted { $0.createdAt > $1.createdAt }
    }
}

#Preview {
    DemoUserCredentialsView()
}
