import Passwordless
import SwiftUI

struct DemoRegistrationView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var environment: DemoEnvironmentItems
    @State private var alertItem: AlertItem?
    @State private var username: String = ""
    @State private var firstName: String = ""
    @State private var lastName: String = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            TextField("First Name", text: $firstName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            TextField("Last Name", text: $lastName)
                .textFieldStyle(.roundedBorder)
                .autocorrectionDisabled()
            requestButton
            Spacer()
        }
        .padding()
        .navigationStyle("Registration")
        .alert(item: $alertItem) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }

    private var requestButton: some View {
        Button {
            requestAuthorization()
        } label: {
            HStack {
                Image(systemName: "person.badge.key.fill")
                Text("Register passkey and sign in")
            }
        }
        .disabled(username.isEmpty)
        .tint(.red)
        .buttonStyle(.borderedProminent)
    }
}

// MARK: Passwordless SDK integration

extension DemoRegistrationView {
    private func requestAuthorization() {
        Task {
            environment.showLoader = true
            defer { environment.showLoader = false }
            do {
                // 1. Begin registration by requesting a token from your server.
                let registrationToken = await environment.services.demoAPIService.register(
                    username: username,
                    firstName: firstName,
                    lastName: lastName
                ).token

                // 2. Register the token through the SDK, which creates a private key for the token.
                let verifyToken = try await environment.services.passwordlessClient.register(token: registrationToken)
                
                // 3. With the resulting token from the SDK, verify it with your backend to get an authorization token.
                let jwtToken = await environment.services.demoAPIService.login(verifyToken: verifyToken)
                environment.authToken = jwtToken.jwtToken
                environment.userId = try jwtToken.jwtToken.decodedUserId()

                await MainActor.run {
                    dismiss()
                }
            } catch PasswordlessClientError.authorizationCancelled {
                print("Cancelled")
            } catch {
                print(error)

                alertItem = AlertItem(
                    title: "Registration issue",
                    message: "\(error)"
                )
            }
        }
    }
}

#Preview {
    DemoRegistrationView()
}
