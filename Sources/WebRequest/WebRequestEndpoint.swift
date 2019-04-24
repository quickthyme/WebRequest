import Foundation

public protocol WebRequestEndpoint {
    var method  : WebRequest.Method { get }
    var urlString : String? { get }
    var urlBase : String { get }
    var urlPath : String { get }
}

public struct DefaultEndpoint : WebRequestEndpoint {
    public let method: WebRequest.Method
    public let urlString: String?
    public let urlBase: String
    public let urlPath: String

    public init(_ method: WebRequest.Method,
                _ urlString: String?) {
        self.method = method
        self.urlString = urlString
        self.urlBase = ""
        self.urlPath = ""
    }

    public init(_ method: WebRequest.Method,
                _ urlBase: String,
                _ urlPath: String) {
        self.method = method
        self.urlString = nil
        self.urlBase = urlBase
        self.urlPath = urlPath
    }
}
