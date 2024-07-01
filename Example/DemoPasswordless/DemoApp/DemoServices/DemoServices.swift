import Foundation
import Passwordless

class DemoServices {
    let demoAPIService = DemoAppAPIService(demoApiUrl: "https://demo.passwordless.dev")

    let passwordlessClient = PasswordlessClient(
        apiUrl: "https://v4.passwordless.dev",
        apiKey: "pwdemo:public:5aec1f24f65343239bf4e1c9a852e871",
        rpId: "demo.passwordless.dev",
        // origin: "ios:bundle-id:com.8bit.bitwarden.passwordlessios",
        origin: "https://demo.passwordless.dev",
        relyingPartyIdentifier: "demo.passwordless.dev"
    )
}
