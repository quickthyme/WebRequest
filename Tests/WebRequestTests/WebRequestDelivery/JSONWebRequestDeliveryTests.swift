
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

    struct DummyError: Error {}

    func test_when_completion_handler_throws_it_rethrows() {
        let endpoint = DefaultEndpoint.init(.GET, nil)
        let delivery = JSONWebRequestDelivery()

        let subject = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            completion: { _, _ in throw DummyError() }
        )

        XCTAssertThrowsError(try subject.execute())
    }

    func test_can_execute_real_live_json_request_with_passing_result() {
        startServer()
        let expectation = self.expectation(description: "RealJSONCompleted")
        let endpoint = MockGETEndpoint()
        let delivery = JSONWebRequestDelivery()

        var resultStatus: Int = -1
        var resultObject: [AnyHashable: Any]?

        let subject = WebRequest(
            endpoint: endpoint,
            headers: nil,
            urlParameters: nil,
            bodyParameters: nil,
            delivery: delivery,
            completion: { [expectation] result, request in
                resultStatus = result.status
                resultObject = try? JSONSerialization
                    .jsonObject(with: result.data ?? Data(),
                                options: .allowFragments)
                    as? [AnyHashable: Any]
                expectation.fulfill()
            }
        )

        try! subject.execute()

        waitForExpectations(timeout: 60.0) { _ in
            self.stopServer()
            XCTAssertEqual(resultStatus, 200)
            XCTAssertEqual(resultObject!["title"] as! String, "Awake")
        }
    }
}
