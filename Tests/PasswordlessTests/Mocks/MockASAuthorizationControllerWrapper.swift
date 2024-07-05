import AuthenticationServices
import Foundation
@testable import Passwordless

class MockASAuthorizationControllerWrapper: NSObject, ASAuthorizationControllerWrapperProtocol {
    var calledCancel = false
    var calledCreateControllerForAssertion = false
    var calledCreateControllerForRegistration = false
    var calledPerformRequests = false
    var calledPerformAutoFillAssistedRequests = false

    weak var delegate: AuthorizationControllerWrapperDelegate?

    func createControllerForAssertion(rpId: String, challenge: Data) {
        calledCreateControllerForAssertion = true
    }

    func createControllerForRegistration(rpId: String, challenge: Data, name: String, userId: Data) {
        calledCreateControllerForRegistration = true
    }

    func performRequests() {
        calledPerformRequests = true
    }

    func performAutoFillAssistedRequests() {
        calledPerformAutoFillAssistedRequests = true
    }

    func cancel() {
        calledCancel = true
        delegate?.didCompleteWithError(error: ASAuthorizationError(.canceled))
    }
}
