import XCTest
import WebRequest

class ProgressFileDownloadWebRequestDeliveryTests: XCTestCase {

    var testPercent: Int = -99
    var testfilePath: URL?
    var testStatus: Int = -99
    var expectation:XCTestExpectation?
    var webRequest: WebRequest?
    let subject =  ProgressFileDownloadWebRequestDelivery(targetURL: URL(string: "test.file")!)
    var urlSession: MockURLSession?
    var successfulResponse: HTTPURLResponse?
    var unsuccessfulResponse: HTTPURLResponse?
    var downloadRequest: URLSessionDownloadTask?
    let testURL = URL(string: "test.file")!

    override func setUp() {
        testPercent = -9999
        testfilePath = nil
        testStatus = -999
        urlSession = MockURLSession(configuration: URLSessionConfiguration())
        successfulResponse = HTTPURLResponse(url: testURL, statusCode: 200, httpVersion: nil, headerFields: nil)
        unsuccessfulResponse = HTTPURLResponse(url: testURL, statusCode: 404, httpVersion: nil, headerFields: nil)
        downloadRequest = MockURLSessionDownloadTask(mockSession: urlSession!, url: testURL)
        urlSession!.mockResponse = successfulResponse
        
        webRequest = WebRequest(urlString: "https://path/to/pdf.pdf",
                            method: .GET,
                            delivery: subject,
                            validator: BasicHTTPResultValidator(),
                            onDataReceived: onDataReceived,
                            completion: completion)
        
         subject.webRequest = webRequest;
    }
    
    func onDataReceived(result: WebRequest.Result, request: WebRequest, percentComplete: Int, filePath: URL) {
        testPercent = percentComplete
        testfilePath = filePath
        testStatus = result.status
        self.expectation!.fulfill()
    }
    
    func completion(result: WebRequest.Result, request: WebRequest) {
        testStatus = result.status
        self.expectation!.fulfill()
    }

    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_zero_bytes_are_written_THEN_percentComplete_is_0() {
        
        expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_zero_bytes_are_written_THEN_percentComplete_is_0")
        subject.urlSession(urlSession!, downloadTask: downloadRequest!, didWriteData: 0, totalBytesWritten: 0, totalBytesExpectedToWrite: 100)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(self.testPercent, 0)
            XCTAssertEqual(self.testStatus, 200)
            XCTAssertEqual(self.testfilePath!.absoluteString, "test.file")
        }
    }
    
    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_20_bytes_are_written_out_of_100_THEN_percentComplete_is_20() {
        
        expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_20_bytes_are_written_out_of_100_THEN_percentComplete_is_20")
    
        subject.urlSession(urlSession!, downloadTask: downloadRequest!, didWriteData: 0, totalBytesWritten: 20, totalBytesExpectedToWrite: 100)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(self.testPercent, 20)
            XCTAssertEqual(self.testStatus, 200)
            XCTAssertEqual(self.testfilePath!.absoluteString, "test.file")
        }
    }
    
    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_91_bytes_are_written_out_of_100_THEN_percentComplete_is_20() {
        
        expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_91_bytes_are_written_out_of_100_THEN_percentComplete_is_20")
        subject.urlSession(urlSession!, downloadTask: downloadRequest!, didWriteData: 0, totalBytesWritten: 91, totalBytesExpectedToWrite: 100)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(self.testPercent, 91)
            XCTAssertEqual(self.testStatus, 200)
            XCTAssertEqual(self.testfilePath!.absoluteString, "test.file")
        }
    }

    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_THEN_percentComplete_is_20() {
        
        expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_THEN_percentComplete_is_20")
        expectation!.expectedFulfillmentCount = 2
        subject.urlSession(urlSession!, downloadTask: downloadRequest!, didFinishDownloadingTo: testURL)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(self.testPercent, 100)
            XCTAssertEqual(self.testStatus, 200)
            XCTAssertEqual(self.testfilePath!.absoluteString, "test.file")
        }
    }
    
    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_AND_response_is_200_percentComplete_is_100() {
        
        expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_AND_response_is_200_percentComplete_is_100")
        expectation?.expectedFulfillmentCount = 2
        subject.urlSession(urlSession!, downloadTask: downloadRequest!, didFinishDownloadingTo: testURL)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(self.testPercent, 100)
            XCTAssertEqual(self.testStatus, 200)
            XCTAssertEqual(self.testfilePath!.absoluteString, "test.file")
        }
    }
    
    func test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_AND_response_is_not_200_percentComplete_is_0() {
        
        expectation = self.expectation(description: "test_given_ProgressFileDownloadWebRequestDelivery_WHEN_didFinishDownloading_AND_response_is_not_200_percentComplete_is_0")
        expectation?.expectedFulfillmentCount = 2
        urlSession!.mockResponse = unsuccessfulResponse
        subject.urlSession(urlSession!, downloadTask: downloadRequest!, didFinishDownloadingTo: testURL)
        
        waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(self.testPercent, 0)
            XCTAssertEqual(self.testStatus, 404)
            XCTAssertEqual(self.testfilePath!.absoluteString, "test.file")
        }
    }
}
