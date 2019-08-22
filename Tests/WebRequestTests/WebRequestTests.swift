
import XCTest
import WebRequest

class WebRequestTests: XCTestCase {

    override func setUp() {
        WebRequest.isDisabled = false
    }

    func test_default_web_request_properties_should_be_nil() {
        let request = WebRequest()
        XCTAssertNil(request.headers)
        XCTAssertNil(request.urlParameters)
        XCTAssertNil(request.bodyParameters)
        XCTAssertNil(request.delivery)
        XCTAssertNil(request.completion)
    }

    func test_can_execute_basic_get_request_with_passing_result() {
        let expectation = self.expectation(description: "BasicGETCompleted")
        let endpoint = MockGETEndpoint()
        let delivery = MockWebRequestDelivery()

        let subject = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            validator: BasicHTTPResultValidator(),
            completion: { [expectation] result, request in
                XCTAssert(result.status == MockWebRequestDelivery.TestStatusCode.pass.rawValue)
                expectation.fulfill()
            }
        )

        try! subject.execute()

        waitForExpectations(timeout: 2.0) { _ in
        }
    }

    func test_can_execute_basic_POST_request_with_passing_result() {
        let expectation = self.expectation(description: "BasicPOSTCompleted")
        let endpoint = MockPOSTEndpoint()
        let delivery = MockWebRequestDelivery()
        let testString = "http://127.0.0.1:8080/translate"

        let subject = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            validator: BasicHTTPResultValidator(),
            completion: { [expectation] result, request in
                XCTAssert(result.status == MockWebRequestDelivery.TestStatusCode.pass.rawValue)
                XCTAssertNotNil(result.data)
                let resultString = String(data: result.data!, encoding: .utf8)
                XCTAssertNotNil(resultString)
                XCTAssert(resultString! == testString)
                expectation.fulfill()
            }
        )

        try! subject.execute()

        waitForExpectations(timeout: 2.0) { _ in
        }
    }

    func test_given_test_mode_enabled_when_it_is_executed_then_it_does_not_deliver() {
        let endpoint = MockPOSTEndpoint()
        let delivery = MockWebRequestDelivery()

        let subject = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            validator: BasicHTTPResultValidator(),
            completion: nil
        )

        WebRequest.isDisabled = true
        try! subject.execute()

        XCTAssertFalse(delivery.didCall_deliver)
    }
}
