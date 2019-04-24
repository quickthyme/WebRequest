
import XCTest
import WebRequest

class JSONWebRequestDeliveryTests: XCTestCase {

    var server: TestHTTPServer!

    func startServer() {
        server = TestHTTPServer()
        server.responsePayload = "{ \"title\": \"Awake\" }"
        server.portNumber = 8080
        server.start()
    }

    func stopServer() {
        server.stop()
    }

    func x_test_can_execute_real_live_json_request_with_passing_result() {
        startServer()
        let expectation = self.expectation(description: "RealJSONCompleted")
        let endpoint = MockGETEndpoint()
        let delivery = JSONWebRequestDelivery()

        var resultStatus: Int = -1
        var resultObject: [AnyHashable: Any]?

        let testRequest = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            completion: { [expectation] result, request in
                resultStatus = result.status
                resultObject = (
                    try? JSONSerialization
                        .jsonObject(with: result.data!, options: JSONSerialization.ReadingOptions.allowFragments)
                        as? [AnyHashable: Any])!
                expectation.fulfill()
            }
        )

        testRequest.execute()

        waitForExpectations(timeout: 1.0) { _ in
            self.stopServer()
            XCTAssertEqual(resultStatus, 200)
            XCTAssertEqual(resultObject!["title"] as! String, "Awake")
        }
    }
}
