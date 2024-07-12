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

    func testCancel() async throws {
        await subject.cancelExistingRequests()
        XCTAssertTrue(keyCredentialProvider.calledCancelExistingRequest)
    }

    func testRegister() async throws {
        _ = try await subject.register(token: "")
        XCTAssertTrue(apiService.calledRegisterBegin)
        XCTAssertTrue(keyCredentialProvider.calledRequestAuthorization)
        XCTAssertTrue(apiService.calledRegisterComplete)
    }

    func testSignInWithAlias() async throws {
        _ = try await subject.signIn(alias: "Bender")
        XCTAssertTrue(apiService.calledSignInBegin)
        XCTAssertTrue(keyCredentialProvider.calledRequestAssertion)
        XCTAssertTrue(apiService.calledSignInComplete)
    }

    func testSignInWithUserId() async throws {
        _ = try await subject.signIn(userId: "12345")
        XCTAssertTrue(apiService.calledSignInBegin)
        XCTAssertTrue(keyCredentialProvider.calledRequestAssertion)
        XCTAssertTrue(apiService.calledSignInComplete)
    }

    func testSignInWithAutofill() async throws {
        _ = try await subject.signInWithAutofill()
        XCTAssertTrue(apiService.calledSignInBegin)
        XCTAssertTrue(keyCredentialProvider.calledRequestAssertion)
        XCTAssertTrue(apiService.calledSignInComplete)
    }

    func testSignInWithDiscoverable() async throws {
        _ = try await subject.signinWithDiscoverable()
        XCTAssertTrue(apiService.calledSignInBegin)
        XCTAssertTrue(keyCredentialProvider.calledRequestAssertion)
        XCTAssertTrue(apiService.calledSignInComplete)
    }
}
