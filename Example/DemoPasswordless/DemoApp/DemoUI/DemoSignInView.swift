import Passwordless
import SwiftUI

struct DemoSignInView: View {
    @EnvironmentObject private var environment: DemoEnvironmentItems
    @State private var alertItem: AlertItem?
    @State private var username: String = ""

    var body: some View {
        VStack {
            TextField("Username", text: $username)
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)

            signInButton
            Spacer()
            createButton
        }
        .padding()
        .navigationStyle("Sign In")
        .onAppear {
            startAuthorization(autoFill: true)
        }
        .onDisappear {
            Task {
                await environment.services.passwordlessClient.cancelExistingRequests()
            }
        }
        .alert(item: $alertItem) { item in
            Alert(
                title: Text(item.title),
                message: Text(item.message),
                dismissButton: .cancel(Text("OK"))
            )
        }
    }

    private var signInButton: some View {
        Button {
            startAuthorization(autoFill: false)
        } label: {
            HStack {
                Image(systemName: "person.badge.key.fill")
                Text("Sign in with passkey")
            }
        }
        .tint(.red)
        .buttonStyle(.borderedProminent)
        .disabled(username.isEmpty)
    }

    private var createButton: some View {
        NavigationLink {
            DemoRegistrationView()
        } label: {
            HStack {
                Image(systemName: "person.fill.badge.plus")
                Text("Create passkey")
            }
        }
        .tint(.red)
        .buttonStyle(.borderedProminent)
    }

    private func startAuthorization(autoFill: Bool) {
        Task {
            if !autoFill {
                environment.showLoader = true
            }
            defer { environment.showLoader = false }

            do {
                let verifyToken = try await environment.services.passwordlessClient.signIn(
                    alias: autoFill ? nil : username
                )
                let jwtToken = await environment.services.demoAPIService.login(verifyToken: verifyToken)
                environment.authToken = jwtToken.jwtToken
            } catch PasswordlessClientError.authorizationCancelled {
                print("Cancelled")
            } catch {
                print(error)

                alertItem = AlertItem(
                    title: "Sign in issue",
                    message: "\(error)"
                )
                    
                startAuthorization(autoFill: true)
            }
        }
    }
}

#Preview {
    DemoSignInView()
}
