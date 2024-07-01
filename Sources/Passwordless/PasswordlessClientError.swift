import Foundation

public enum PasswordlessClientError: Error {
    case authorizationCancelled
    case authorizationError(Error)
    case internalErrorDecodingJson(Error)
    case internalErrorEncodingPayload(Error)
    case internalErrorNetworkRequestFailed(Error)
    case internalErrorNetworkRequestResponseError(Int?, String)
    case internalErrorInvalidURL(String)
    case internalErrorUnableToDecodeChallenge
    case internalErrorUnableToEncodeUserId
}
