# How to Contribute

Our [Contributing Guidelines](https://contributing.bitwarden.com/contributing/) are located in our [Contributing Documentation](https://contributing.bitwarden.com/). The documentation also includes recommended tooling, code style tips, and lots of other great information to get you started.

# Notes on the Example Project

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
