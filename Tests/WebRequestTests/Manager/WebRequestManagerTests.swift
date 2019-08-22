import XCTest
@testable import WebRequest

class WebRequestManagerTests: XCTestCase {

    var subject: WebRequestManager!
    var mockSessionProvider: MockWebRequestSessionProvider!
    var mockApplySession: WebRequestManaging.SessionApplier!

    var capturedRequest: WebRequest?
    var capturedSession: WebRequestSession?

    typealias StatusCode = MockWebRequestDelivery.TestStatusCode

    override func setUp() {
        capturedRequest = nil
        capturedSession = nil

        mockApplySession = {
            self.capturedRequest = $0
            self.capturedSession = $1
            return $0
        }

        mockSessionProvider = MockWebRequestSessionProvider()

        subject = WebRequestManager(sessionProvider: mockSessionProvider,
                                    applySession: mockApplySession)

    }

    func test_begin_request_with_current_session_should_complete() {
        var receivedResult: WebRequest.Result? = nil
        let expectComplete = expectation(description: "should complete")

        mockSessionProvider.current = MockWebRequestSession()
        let mockDelivery = MockWebRequestDelivery()
        mockDelivery.testStatusCode = .pass

        let request = WebRequest(urlString: "http://localhost:8888",
                                 method: .GET,
                                 delivery: mockDelivery,
                                 validator: BasicHTTPResultValidator(),
                                 completion: ({ result, _ in
                                    receivedResult = result
                                    expectComplete.fulfill()
                                 }))

        try! subject.begin(request: request)

        wait(for: [expectComplete], timeout: 4.0)

        XCTAssertTrue(mockDelivery.didCall_deliver)
        XCTAssert(receivedResult!.status == StatusCode.pass.rawValue)
    }

    func test_begin_request_without_current_session_should_not_deliver_and_instead_complete_with_unauthorized_status() {
        var receivedResult: WebRequest.Result? = nil
        let expectComplete = expectation(description: "should complete 401")

        mockSessionProvider.current = nil
        let mockDelivery = MockWebRequestDelivery()
        mockDelivery.testStatusCode = .unauthorized

        let request = WebRequest(urlString: "http://localhost:8888",
                                 method: .GET,
                                 delivery: mockDelivery,
                                 validator: BasicHTTPResultValidator(),
                                 completion: ({ result, _ in
                                    receivedResult = result
                                    expectComplete.fulfill()
                                 }))

        try! subject.begin(request: request)

        wait(for: [expectComplete], timeout: 4.0)

        XCTAssertFalse(mockDelivery.didCall_deliver)
        XCTAssert(receivedResult!.status == StatusCode.unauthorized.rawValue)
    }

    func test_begin_request_when_getting_unauthorized_result_should_attempt_refresh_once_and_raise_401_if_call_fails_again() {
        var receivedResult: WebRequest.Result? = nil
        let expectComplete = expectation(description: "should refresh")

        mockSessionProvider.current = MockWebRequestSession()
        mockSessionProvider.refreshSuccessSession = MockWebRequestSession()

        let mockDelivery = MockWebRequestDelivery()
        mockDelivery.testStatusCode = .unauthorized

        let request = WebRequest(urlString: "http://localhost:8888",
                                 method: .GET,
                                 delivery: mockDelivery,
                                 validator: BasicHTTPResultValidator(),
                                 completion: ({ result, _ in
                                    receivedResult = result
                                    expectComplete.fulfill()
                                 }))

        try! subject.begin(request: request)

        wait(for: [expectComplete], timeout: 6.0)

        XCTAssertTrue(mockDelivery.didCall_deliver)
        XCTAssertEqual(mockSessionProvider.timesCalled_refresh, 1)
        XCTAssert(receivedResult!.status == StatusCode.unauthorized.rawValue)
    }

    func test_flush_clears_all_pending_requests_and_resets_busy_status() {
        subject.flush()

        XCTAssertEqual(subject.requests.count, 0)
        XCTAssertFalse(subject.isBusy)
    }
}
