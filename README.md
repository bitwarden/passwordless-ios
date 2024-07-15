![Passwordless by Bitwarden](<./docs/pwLogo.png>)

# Passwordless.dev iOS Client SDK

The purpose of this SDK is to be able to easily integrate [passkeys](https://developer.apple.com/passkeys/) into your iOS app with the help of the [Passwordless.dev](https://bitwarden.com/products/passwordless/) management system. An example project named `DemoPasswordless` is provided for illustrative purposes, and is contained in this repository along with the SDK.

## System Overview
[Passwordless.dev](https://bitwarden.com/products/passwordless/) consists of three key parts:

1. An open-source client side SDK (for example, this iOS SDK), used by your app/website to initiate passkey authorization requests on the end-user's device and to make requests to the passwordless.dev APIs.
2. A public RESTful API used to complete FIDO2 WebAuthn cryptographic exchanges with your app.
3. A private RESTful API used to initiate key registrations, verify signins, and retrieve keys for end-users.

Please read the [Passwordless.dev documentation](https://docs.passwordless.dev/) for more details.

## apple-app-site-association

Apple requires associated domains to be set up to perform passkey registration and assertions. For more details on setting up an apple-app-site-association, see [Apple's documentation](https://developer.apple.com/documentation/Xcode/supporting-associated-domains). 

For passkeys, you need to set up a `webcredentials` section for your app. 

You can view an [example](https://demo.passwordless.dev/.well-known/apple-app-site-association) of an apple-app-site-association that corresponds to the `DemoPasswordless` app provided in this repository.

Here is an example of what the entitlements should look like in Xcode when the AASA is hosted on `demo.passwordless.dev`:

![Entitlements](<./docs/entitlements.png>)

## Getting Started with the iOS SDK

### Requirements

* **Minimum iOS Version:** iOS 16
* **Additional Capabilities:** 
  * _Associate Domains_ are needed to add the domain of where the AASA file is hosted.

### Swift Package Manager

The SDK can be added to your project via [Swift Package Manager](https://www.swift.org/package-manager/). You can then access the SDK functionality using `import Passwordless`.

### Initialization

The SDK provides a `PasswordlessClient` object that needs to be initialized with a `PasswordlessConfig` configuration. The configuration contains the API URL and API key needed to interface with [Passwordless.dev](https://bitwarden.com/products/passwordless/). It also requires the relying party ID, which represents the domain of your server that hosts an apple-app-site-association file with your app's team ID and bundle ID.

You will need to register with [Passwordless.dev](https://bitwarden.com/products/passwordless/) to obtain an API key.

Here is an example of a configuration:

```swift
let passwordlessClient = PasswordlessClient(
    config: PasswordlessConfig(
        apiKey: "<YOUR API KEY>",
        rpId: "demo.passwordless.dev"
    )
)
```

### Registration

1. Request a registration token from your public RESTful API with the given username.
2. Pass the registration token to the `PasswordlessClient` via the `register(token:)` function. This will prompt the user to use biometrics to create the local private key needed for validation and send the public key to the Passwordless.dev API. Once complete, a verification token will be returned. See [error section](#error-responses) for possible errors that could be thrown.

```swift
let verifyToken = try await passwordlessClient.register(token: registrationToken)
```

3. Pass the verification token to your public RESTful API to verify and return an authorization token. The user is now logged in to your app.

![Registration Flow](<./docs/Registration.gif>)

### Sign in

There are two main approaches for passkey sign in: auto fill and alias. Also provided are `signinWithDiscoverable()` and `signIn(userId:)` for more advanced use cases.

#### A. Auto Fill
This is when the user taps the username field, and the keyboard appears. If the user taps the auto fill options above the keyboard, then this is the auto fill approach. For this to work correctly, you must call `signInWithAutofill` when your view first appears. This way, by the time the keyboard appears, the OS will have results ready to show.

1. Call `signInWithAutofill()` when your view first appears. Once complete, a verification token will be returned.
    * This function will wait until the user has tapped on an autofill item, it has been canceled in the passkey dialog, or an error has occurred. 
    * If errors are thrown, your app will need to decide whether or not to restart the auto fill sign in process again. 
    * If it is not running, then no options will show in the keyboard, so it usually makes sense to restart the process only in the `authorizationCancelled` case. 
    * Getting an `authorizationError` may be a sign that something is not configured properly within your app, so it may be best to not rerun the auto fill to prevent endless looping errors. See [error section](#error-responses) for possible errors that could be thrown.

```swift
let verifyToken = try await passwordlessClient.signInWithAutofill()
```

2. Pass the verification token to your public RESTful API to verify and return an authorization token. The user is now logged in to your app.

![Auto Fill Sign in Flow](<./docs/SignInAutoFill.gif>)

#### B. Alias 
This is when the user types in a user name, and hits a button within the view to sign in. This will display a different version of the passkey window for the user to select from.

1. Call `signIn(alias:)` with a given alias. Once complete, a verification token will be returned. See [error section](#error-responses) for possible errors that could be thrown.

```swift
let verifyToken = try await passwordlessClient.signIn(alias: username)
```

2. Pass the verification token to your public RESTful API to verify and return an authorization token. The user is now logged in to your app.

![Alias Sign in Flow](<./docs/SignInManual.gif>)

#### C. Discoverable
This is if you would like to show the passkey modal manually without using the keyboard shortcut or having the user type an alias.

#### D. User Id
This is if you already have a user Id and would like to go through the assertion process.

### Error Responses
The PasswordlessClient object can throw the following errors:

| Error | Description |
| --- | --- |
| authorizationCancelled | OS Authorization was cancelled from the key credential provider. |
| authorizationError(Error) | OS Authorization failed from the key credential provider. |
| internalErrorDecodingJson(Error) | There was an issue decoding json to an object from a network response. |
| internalErrorEncodingPayload(Error) | There was an issue encoding json from an object for a network request. |
| internalErrorInvalidURL(String) | The url used to make the network request is invalid. |
| internalErrorNetworkRequestFailed(Error) | An error occurred when making a network request. |
| internalErrorNetworkRequestResponseError(Int?, PasswordlessErrorResponse?) | An error response occurred when making a network request with the given status code and error response if available. |
| internalErrorUnableToDecodeChallenge | The challenge provided is not in the correct format. |
| internalErrorUnableToEncodeUserId | The user Id is not able to be encoded to base 64 Url. |

For internalErrorNetworkRequestResponseError, the PasswordlessErrorResponse can be provided, which contains details about the error from the response. Here's an example of a response error that could be returned:

```json
{
  "type": "https://docs.passwordless.dev/errors#missing_register_token",
  "title": "The token you sent was not correct. The token used for this endpoint should start with 'register_'. Make sure you are not sending the wrong value.",
  "status": 400,
  "errorCode": "missing_register_token"
}
```

And here's an example of how you could view this in your app:

```swift
do {
    let verifyToken = try await passwordlessClient.signIn()
}
catch PasswordlessClientError.authorizationCancelled {
    print("Cancelled")
}
catch let PasswordlessClientError.internalErrorNetworkRequestResponseError(code, response) {
    print("Network Error occurred. Response status code: \(code ?? -1)")
    dump(response)
}
catch {
    print("Some other error occurred: \(error)")
}
```


## Example App

This project contains an example app called DemoPasswordless. It is important to know that if you're planning to run this app, you must configure a few things beforehand:

1. Passkey authorization is tied directly to an apple-app-site-association (AASA) file hosted on your public API.
2. When running the app, your developer account must be on the Apple team designated in the corresponding AASA file, along with a matching bundle ID.

For example, let's say your AASA file looks like this:

```json
{
  "webcredentials": {
    "apps": [
      "Q999999997.com.8bit.bitwarden.passwordlessios"
    ]
  }
}
```

To run the demo app without errors, the app's bundle ID must be `com.8bit.bitwarden.passwordlessios`. Furthermore, your personal developer account must have access to the team ID `Q999999997`.

In the `DemoServices.swift` file, the relying party ID (`rpID`) should be set to the domain where this AASA file is hosted.
