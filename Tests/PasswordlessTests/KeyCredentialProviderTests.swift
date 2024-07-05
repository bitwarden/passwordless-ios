import XCTest
import AuthenticationServices
@testable import Passwordless

final class KeyCredentialProviderTests: XCTestCase {
    let delay: UInt64 = 500000000 // .5 seconds
    var authControllerWrapper: MockASAuthorizationControllerWrapper!
    var subject: KeyCredentialProvider!

    override func setUp() {
        authControllerWrapper = MockASAuthorizationControllerWrapper()
        subject = KeyCredentialProvider(
            rpId: "rpId",
            authControllerWrapper: authControllerWrapper
        )
    }

    func testRequestAuthorization() async throws {
        async let completeTask = Task {
            try await Task.sleep(nanoseconds: delay)
            authControllerWrapper.delegate?.didCompleteWithRegistration(
                attestation: AttestationRawResponse(
                    credentialID: Data(),
                    rawAttestationObject: nil,
                    rawClientDataJSON: Data()
                )
            )
        }

        async let request = try? await subject.requestAuthorization(
            registerResponse: RegisterBeginResponse(
                data: CredentialCreateOptions(
                    challenge: "",
                    user: Fido2User(id: "", name: "")
                ),
                session: ""
            )
        )

        let _: [Any] = await [request as Any, completeTask]

        XCTAssertTrue(authControllerWrapper.calledCreateControllerForRegistration)
        XCTAssertTrue(authControllerWrapper.calledPerformRequests)
    }

    func testRequestAssertionAutoFill() async throws {
        async let completeTask = Task {
            try await Task.sleep(nanoseconds: delay)
            authControllerWrapper.delegate?.didCompleteWithAssertion(
                assertion: AssertionRawResponse(
                    credentialID: Data(),
                    rawAuthenticatorData: Data(),
                    rawClientDataJSON: Data(),
                    signature: Data()
                )
            )
        }

        async let request = try? await subject.requestAssertion(
            signInResponse: SignInBeginResponse(
                data: AssertionOptions(
                    challenge: "",
                    allowCredentials: [],
                    userVerification: .preferred
                ),
                session: ""
            ),
            autoFill: true
        )


        let _: [Any] = await [request as Any, completeTask]

        XCTAssertTrue(authControllerWrapper.calledCreateControllerForAssertion)
        XCTAssertTrue(authControllerWrapper.calledPerformAutoFillAssistedRequests)
    }

    func testRequestAssertionWithoutAutoFill() async throws {
        async let completeTask = Task {
            try await Task.sleep(nanoseconds: delay)
            authControllerWrapper.delegate?.didCompleteWithAssertion(
                assertion: AssertionRawResponse(
                    credentialID: Data(),
                    rawAuthenticatorData: Data(),
                    rawClientDataJSON: Data(),
                    signature: Data()
                )
            )
        }

        async let request = try? await subject.requestAssertion(
            signInResponse: SignInBeginResponse(
                data: AssertionOptions(
                    challenge: "",
                    allowCredentials: [],
                    userVerification: .preferred
                ),
                session: ""
            ),
            autoFill: false
        )

        let _: [Any] = await [request as Any, completeTask]

        XCTAssertTrue(authControllerWrapper.calledCreateControllerForAssertion)
        XCTAssertTrue(authControllerWrapper.calledPerformRequests)
    }

    func testCancelExistingRequest() async throws {
        async let cancelTask = Task {
            try await Task.sleep(nanoseconds: delay)
            _ = await self.subject.cancelExistingRequest()
        }

        // Make an ongoing request so we can cancel it.
        async let request = try? await subject.requestAuthorization(
            registerResponse: RegisterBeginResponse(
                data: CredentialCreateOptions(
                    challenge: "",
                    user: Fido2User(id: "", name: "")
                ),
                session: ""
            )
        )

        let _: [Any] = await [request as Any, cancelTask]

        XCTAssertTrue(authControllerWrapper.calledCancel)
    }

    func testInternalErrorUnableToDecodeChallengeRegister() async {
        do {
            let _ = try await subject.requestAuthorization(
                registerResponse: RegisterBeginResponse(
                    data: CredentialCreateOptions(
                        challenge: "notBase64",
                        user: Fido2User(id: "", name: "")
                    ),
                    session: ""
                )
            )
            XCTFail("Should have thrown exception")
        } catch PasswordlessClientError.internalErrorUnableToDecodeChallenge {
        } catch {
            XCTFail("Should have thrown internalErrorUnableToDecodeChallenge exception")
        }
    }

    func testInternalErrorUnableToDecodeChallengeSignIn() async {
        do {
            let _ = try await subject.requestAssertion(
                signInResponse: SignInBeginResponse(
                    data: AssertionOptions(
                        challenge: "notBase64",
                        allowCredentials: [],
                        userVerification: .preferred
                    ),
                    session: ""
                ),
                autoFill: false
            )
            XCTFail("Should have thrown exception")
        } catch PasswordlessClientError.internalErrorUnableToDecodeChallenge {
        } catch {
            XCTFail("Should have thrown internalErrorUnableToDecodeChallenge exception")
        }
    }

    func testRequestAuthorizationFailure() async throws {
        async let failTask = Task {
            try await Task.sleep(nanoseconds: delay)
            authControllerWrapper.delegate?.didCompleteWithError(error: ASAuthorizationError(.failed))
        }

        async let request = try? await subject.requestAuthorization(
            registerResponse: RegisterBeginResponse(
                data: CredentialCreateOptions(
                    challenge: "",
                    user: Fido2User(id: "", name: "")
                ),
                session: ""
            )
        )

        let _: [Any] = await [request as Any, failTask]

        XCTAssertTrue(authControllerWrapper.calledCreateControllerForRegistration)
        XCTAssertTrue(authControllerWrapper.calledPerformRequests)
    }

    func testRequestAssertionFailure() async throws {
        async let failTask = Task {
            try await Task.sleep(nanoseconds: delay)
            authControllerWrapper.delegate?.didCompleteWithError(error: ASAuthorizationError(.failed))
        }

        async let request = try? await subject.requestAssertion(
            signInResponse: SignInBeginResponse(
                data: AssertionOptions(
                    challenge: "",
                    allowCredentials: [],
                    userVerification: .preferred
                ),
                session: ""
            ),
            autoFill: true
        )


        let _: [Any] = await [request as Any, failTask]

        XCTAssertTrue(authControllerWrapper.calledCreateControllerForAssertion)
        XCTAssertTrue(authControllerWrapper.calledPerformAutoFillAssistedRequests)
    }
}
