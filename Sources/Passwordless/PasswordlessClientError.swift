import Foundation

// MARK: PasswordlessClientError

/// Errors that can be thrown from the PasswordlessClient
///
public enum PasswordlessClientError: Error {
    /// OS Authorization was cancelled from the key credential provider.
    case authorizationCancelled

    /// OS Authorization failed from the key credential provider.
    case authorizationError(Error)

    /// There was an issue decoding json to an object from a network response.
    case internalErrorDecodingJson(Error)

    /// There was an issue encoding json from an object for a network request.
    case internalErrorEncodingPayload(Error)

    /// The url used to make the network request is invalid.
    case internalErrorInvalidURL(String)

    /// An error occurred when making a network request.
    case internalErrorNetworkRequestFailed(Error)

    /// An error response occurred when making a network request with the given status code and response body.
    case internalErrorNetworkRequestResponseError(Int?, PasswordlessErrorResponse?)

    /// The challenge provided is not in the correct format.
    case internalErrorUnableToDecodeChallenge

    /// The user Id is not able to be encoded to base 64 Url.
    case internalErrorUnableToEncodeUserId
}
