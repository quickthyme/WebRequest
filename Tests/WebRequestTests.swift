
import XCTest
@testable import WebRequest

class WebRequestTests: XCTestCase {

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

        let testRequest = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            completion: { [expectation] result, request in
                XCTAssert(result.status == MockWebRequestDelivery.TestStatusCode.pass.rawValue)
                expectation.fulfill()
            }
        )

        testRequest.execute()

        waitForExpectations(timeout: 2.0) { _ in
        }
    }

    func test_can_execute_basic_POST_request_with_passing_result() {
        let expectation = self.expectation(description: "BasicPOSTCompleted")
        let endpoint = MockPOSTEndpoint()
        let delivery = MockWebRequestDelivery()
        let testString = "http://127.0.0.1:8080/translate"

        let testRequest = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            completion: { [expectation] result, request in
                XCTAssert(result.status == MockWebRequestDelivery.TestStatusCode.pass.rawValue)
                XCTAssertNotNil(result.data)
                let resultString = String(data: result.data!, encoding: .utf8)
                XCTAssertNotNil(resultString)
                XCTAssert(resultString! == testString)
                expectation.fulfill()
            }
        )

        testRequest.execute()

        waitForExpectations(timeout: 2.0) { _ in
        }
    }
}
