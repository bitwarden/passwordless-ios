import Passwordless
import SwiftUI

struct DemoSignInView: View {
    @EnvironmentObject private var environment: DemoEnvironmentItems
    @State private var alertItem: AlertItem?
    @State private var username: String = ""

    var body: some View {
        VStack {
            Image(.logo)
                .resizable()
                .frame(width: 150, height: 150)
                .padding(.vertical, 24)
            TextField("Username", text: $username)
                .autocorrectionDisabled()
                .textFieldStyle(.roundedBorder)
                .textContentType(.username)

            signInButton
            Spacer()
            createButton
        }
        .padding()
        .ignoresSafeArea(.keyboard)
        .navigationStyle("Sign In")
        .onAppear {
            if !Preview.inPreviewMode {
                startAuthorization(autoFill: true)
            }
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
}

// MARK: Passwordless SDK integration

private extension DemoSignInView {
    private func startAuthorization(autoFill: Bool) {
        Task {
            defer { environment.showLoader = false }

            do {
                let verifyToken: String
                if autoFill {
                    // 1a. If autofill mode, begin sign in process to monitor for keyboard shortcut.
                    verifyToken = try await environment.services.passwordlessClient.signInWithAutofill()
                    environment.showLoader = true
                } else {
                    // 1b. If signing in from user manual entry, begin sign in process immediately.
                    environment.showLoader = true
                    verifyToken = try await environment.services.passwordlessClient.signIn(alias: username)
                }

                // 2. With the resulting token from the SDK, verify it with your backend to get an authorization token.
                let jwtToken = await environment.services.demoAPIService.login(verifyToken: verifyToken)
                environment.authToken = jwtToken.jwtToken
                environment.userId = try jwtToken.jwtToken.decodedUserId()
            } catch PasswordlessClientError.authorizationCancelled {
                print("Cancelled")
            } catch PasswordlessClientError.authorizationError(let error) {
                alertItem = AlertItem(
                    title: "Authorization Failure",
                    message: "\(error.localizedDescription)"
                )
            }
            catch {
                print(error)

                alertItem = AlertItem(
                    title: "Sign in issue",
                    message: "\(error)"
                )
                    
                // Start listening again for autofill.
                startAuthorization(autoFill: true)
            }
        }
    }
}

#Preview {
    DemoSignInView()
}
