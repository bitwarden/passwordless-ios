import XCTest
@testable import Passwordless

final class APIServiceTests: XCTestCase {
    var subject: APIService!

    override func setUp() {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        let mockNetworking = MockPasswordlessNetworking(urlSession: urlSession)

        subject = APIService(
            config: PasswordlessConfig(
                apiUrl: "https://example.com",
                apiKey: "1234",
                rpId: "example.com",
                origin: "example.com",
                networking: mockNetworking
            )
        )
    }

    override func tearDown() {
        MockURLProtocol.error = nil
        MockURLProtocol.requestHandler = nil
    }

    func testRegisterBegin() async throws {
        MockURLProtocol.mockSuccessFromJson(jsonFile: "RegisterBegin")
        _ = try await subject.registerBegin(token: "some-token")
    }

    func testRegisterComplete() async throws {
        MockURLProtocol.mockSuccessFromJson(jsonFile: "RegisterComplete")

        _ = try await subject.registerComplete(
            requestModel: RegisterCompleteRequest(
                session: "",
                response: AttestationRawResponse(
                    credentialID: Data(),
                    rawAttestationObject: Data(),
                    rawClientDataJSON: Data()
                ),
                origin: "",
                rpId: "",
                nickname: nil
            )
        )
    }

    func testSignInBegin() async throws {
        MockURLProtocol.mockSuccessFromJson(jsonFile: "SignInBegin")
        _ = try await subject.signInBegin()
    }

    func testSignInComplete() async throws {
        MockURLProtocol.mockSuccessFromJson(jsonFile: "SignInComplete")
        _ = try await subject.signInComplete(
            requestModel: SignInCompleteRequest(
                session: "",
                response: AssertionRawResponse(
                    credentialID: Data(),
                    rawAuthenticatorData: Data(),
                    rawClientDataJSON: Data(),
                    signature: Data()
                ),
                origin: "",
                rpId: ""
            )
        )
    }

    func testInternalErrorInvalidURL() async throws {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [MockURLProtocol.self]
        let urlSession = URLSession.init(configuration: configuration)
        let mockNetworking = MockPasswordlessNetworking(urlSession: urlSession)

        subject = APIService(
            config: PasswordlessConfig(
                apiUrl: "\":",
                apiKey: "1234",
                rpId: "example.com",
                origin: "example.com",
                networking: mockNetworking
            )
        )

        do {
            _ = try await subject.signInBegin()
            XCTFail("Should have thrown exception")
        } catch PasswordlessClientError.internalErrorInvalidURL {
        } catch {
            XCTFail("Should have thrown internalErrorInvalidURL exception")
        }
    }

    func testInternalErrorNetworkRequestFailed() async throws {
        MockURLProtocol.error = NSError(domain: "", code: -1)
        do {
            _ = try await subject.signInBegin()
            XCTFail("Should have thrown exception")
        } catch PasswordlessClientError.internalErrorNetworkRequestFailed {
        } catch {
            XCTFail("Should have thrown internalErrorNetworkRequestFailed exception")
        }
    }

    func testInternalErrorNetworkRequestResponseError() async throws {
        MockURLProtocol.mockSuccessFromJson(jsonFile: "SignInBegin", statusCode: 500)
        do {
            _ = try await subject.signInBegin()
            XCTFail("Should have thrown exception")
        } catch let PasswordlessClientError.internalErrorNetworkRequestResponseError(statusCode, errorResponse) {
            XCTAssertEqual(statusCode, 500)
            XCTAssertNil(errorResponse)
        } catch {
            XCTFail("Should have thrown internalErrorNetworkRequestResponseError exception")
        }
    }

    func testInternalErrorNetworkRequestResponseErrorWithBody() async throws {
        MockURLProtocol.mockSuccessFromJson(jsonFile: "ErrorResponse", statusCode: 400)
        do {
            _ = try await subject.signInBegin()
            XCTFail("Should have thrown exception")
        } catch let PasswordlessClientError.internalErrorNetworkRequestResponseError(statusCode, errorResponse) {
            XCTAssertEqual(statusCode, 400)
            XCTAssertNotNil(errorResponse)
        } catch {
            XCTFail("Should have thrown internalErrorNetworkRequestResponseError exception")
        }
    }

    func testInternalErrorDecodingJson() async throws {
        MockURLProtocol.mockSuccessFromJson(jsonFile: "UnknownObject")
        do {
            _ = try await subject.signInBegin()
            XCTFail("Should have thrown exception")
        } catch PasswordlessClientError.internalErrorDecodingJson {
        } catch {
            XCTFail("Should have thrown internalErrorDecodingJson exception")
        }
    }
}
