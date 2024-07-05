import XCTest
@testable import Passwordless

final class PasswordlessClientTests: XCTestCase {
    var apiService: MockAPIService!
    var keyCredentialProvider: MockKeyCredentialProvider!
    var subject: PasswordlessClient!

    override func setUp() {
        apiService = MockAPIService()
        keyCredentialProvider = MockKeyCredentialProvider()

        subject = PasswordlessClient(
            config: PasswordlessConfig(
                apiUrl: "https://example.com",
                apiKey: "1234",
                rpId: "example.com",
                origin: "example.com"
            ),
            apiService: apiService,
            keyProvider: keyCredentialProvider
        )
    }

    func testRegister() async throws {
        _ = try await subject.register(token: "")
        XCTAssertTrue(apiService.calledRegisterBegin)
        XCTAssertTrue(keyCredentialProvider.calledRequestAuthorization)
        XCTAssertTrue(apiService.calledRegisterComplete)
    }

    func testSignIn() async throws {
        _ = try await subject.signIn()
        XCTAssertTrue(apiService.calledSignInBegin)
        XCTAssertTrue(keyCredentialProvider.calledRequestAssertion)
        XCTAssertTrue(apiService.calledSignInComplete)
    }

    func testCancel() async throws {
        await subject.cancelExistingRequests()
        XCTAssertTrue(keyCredentialProvider.calledCancelExistingRequest)
    }
}
