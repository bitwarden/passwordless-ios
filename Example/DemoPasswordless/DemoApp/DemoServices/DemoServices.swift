import Foundation
import Passwordless

/// IMPORTANT: This demo app will not work for you unless you are on the Bitwarden Apple Development team.

class DemoServices {
    /// This is a service that interacts with your backend to begin registration and sign in requests,
    let demoAPIService = DemoAppAPIService(demoApiUrl: "https://demo.passwordless.dev")

    /// This is the client provided by the Passwordless SDK. The config contains the API URL and API Key needed
    /// to interface with passwordless.dev.  It also requires the relying party ID and origin which represent your
    /// server that hosts an apple-app-site-association file with your app's team ID and bundle id.
    let passwordlessClient = PasswordlessClient(
        config: PasswordlessConfig(
            apiKey: "pwdemo:public:5aec1f24f65343239bf4e1c9a852e871",
            rpId: "demo.passwordless.dev"
        )
    )
}
