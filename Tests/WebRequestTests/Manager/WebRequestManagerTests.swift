import XCTest
@testable import WebRequest

class WebRequestManagerTests: XCTestCase {

    var subject: WebRequestManager!
    var mockSessionProvider: MockWebRequestSessionProvider!
    var mockApplySession: WebRequestManaging.SessionApplier!
    var mockNotificationCenter: MockNotificationCenter!

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

        mockNotificationCenter = MockNotificationCenter()
        subject.notificationCenter = mockNotificationCenter
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

    func test_begin_request_with_multiple_sessions_should_all_complete() {
        var receivedResult1: WebRequest.Result? = nil
        var receivedResult2: WebRequest.Result? = nil
        let expectComplete1 = expectation(description: "1 should complete")
        let expectComplete2 = expectation(description: "2 should complete")

        mockSessionProvider.current = MockWebRequestSession()
        let mockDelivery1 = MockWebRequestDelivery()
        mockDelivery1.testStatusCode = .pass

        let mockDelivery2 = MockWebRequestDelivery()
        mockDelivery2.testStatusCode = .fail

        let request1 = WebRequest(urlString: "http://localhost:8888",
                                  method: .GET,
                                  delivery: mockDelivery1,
                                  validator: BasicHTTPResultValidator(),
                                  completion: ({ result, _ in
                                    receivedResult1 = result
                                    expectComplete1.fulfill()
                                  }))

        let request2 = WebRequest(urlString: "http://localhost:8888",
                                  method: .PUT,
                                  delivery: mockDelivery2,
                                  validator: BasicHTTPResultValidator(),
                                  completion: ({ result, _ in
                                    receivedResult2 = result
                                    expectComplete2.fulfill()
                                  }))

        try! subject.begin(request: request1)
        try! subject.begin(request: request2)

        wait(for: [expectComplete1, expectComplete2], timeout: 4.0)

        XCTAssertTrue(mockDelivery1.didCall_deliver)
        XCTAssertTrue(mockDelivery2.didCall_deliver)
        XCTAssert(receivedResult1!.status == StatusCode.pass.rawValue)
        XCTAssert(receivedResult2!.status == StatusCode.fail.rawValue)
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
        XCTAssertTrue(mockNotificationCenter.didPost)
        XCTAssertEqual(mockNotificationCenter.postedNotificationName, WebRequestUnauthorizedResponseNotification)
    }

    func test_begin_request_when_getting_unauthorized_result_should_attempt_refresh_once_then_raise_401_and_post_notification_if_call_fails_again() {
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
        XCTAssertTrue(mockNotificationCenter.didPost)
        XCTAssertEqual(mockNotificationCenter.postedNotificationName, WebRequestUnauthorizedResponseNotification)
    }
}
