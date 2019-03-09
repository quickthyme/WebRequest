
import Foundation
import WebRequest

class MockGETEndpoint: WebRequestEndpoint {
    var method          : WebRequest.Method = .GET
    var urlString       : String? = nil
    var urlBase         : String = "http://127.0.0.1:8080"
    var urlPath         : String = "/translate"
}

class MockPOSTEndpoint: WebRequestEndpoint {
    var method          : WebRequest.Method = .POST
    var urlString       : String? = nil
    var urlBase         : String = "http://127.0.0.1:8080"
    var urlPath         : String = "/translate"
}
