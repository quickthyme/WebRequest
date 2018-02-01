
import Foundation
@testable import WebRequest

class MockGETEndpoint: WebRequestEndpoint {
    var method          : WebRequest.Method = .GET
    var urlBase         : String = "http://127.0.0.1:8080"
    var urlPath         : String = "/translate"
}

class MockPOSTEndpoint: WebRequestEndpoint {
    var method          : WebRequest.Method = .POST
    var urlBase         : String = "http://127.0.0.1:8080"
    var urlPath         : String = "/translate"
}
