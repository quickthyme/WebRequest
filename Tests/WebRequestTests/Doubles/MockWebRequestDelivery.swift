import Foundation
import XCTest
import WebRequest

class MockWebRequestDelivery : WebRequestDelivery {

    enum TestStatusCode : Int {
        case fail = 0, pass = 1
    }

    var didCall_deliver: Bool = false
    func deliver(request:WebRequest) {
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
        
        self.deliverURL(url, request: request)
    }
    
    private func deliverURL(_ url: URL, request:WebRequest) {
        let data = url.absoluteString.data(using: .utf8)
        send(completion: request.completion, request: request, testStatusCode: .pass, data: data)
    }
    
    private func send(completion:WebRequest.Completion?, request: WebRequest, testStatusCode: TestStatusCode, data: Data? = nil) {
        let result = WebRequest.Result(status: testStatusCode.rawValue, headers:[:], data: data)
        completion?(result, request)
    }
    
}
