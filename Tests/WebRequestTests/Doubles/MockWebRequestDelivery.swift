import Foundation
import XCTest
import WebRequest

class MockWebRequestDelivery : WebRequestDelivery {

    enum TestStatusCode : Int {
        case fail = 0, pass = 200, unauthorized = 401
    }

    var testStatusCode: TestStatusCode = .pass

    var didCall_deliver: Bool = false
    func deliver(request:WebRequest) throws {
        didCall_deliver = true

        let url : URL

        if let urlString = request.endpoint.urlString {
            let turl = URL(string: urlString)
            XCTAssertNotNil(turl)
            url = turl!
        }

        else {
            var urlComponents = URLComponents(string: request.endpoint.urlBase)
            XCTAssertNotNil(urlComponents)
            urlComponents!.path = request.endpoint.urlPath
            let turl = urlComponents!.url
            XCTAssertNotNil(turl)
            url = turl!
        }

        try self.deliverURL(url, request: request)
    }

    private func deliverURL(_ url: URL, request:WebRequest) throws {
        let data = url.absoluteString.data(using: .utf8)
        try complete(request: request, testStatusCode: testStatusCode, data: data)
    }

    private func complete(request: WebRequest, testStatusCode: TestStatusCode, data: Data? = nil) throws {
        let result = WebRequest.Result(status: testStatusCode.rawValue, headers:[:], data: data)
        try request.completion?(result, request)
    }
}
