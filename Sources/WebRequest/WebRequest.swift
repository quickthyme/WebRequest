
import Foundation

public protocol WebRequestEndpoint {
    var method  : WebRequest.Method { get }
    var urlString : String? { get }
    var urlBase : String { get }
    var urlPath : String { get }
}

public protocol WebRequestDelivery {
    func deliver(request:WebRequest)
}

public struct WebResult {
    public var status : Int = -1
    public var headers: [AnyHashable:Any]
    public var data   : Data?

    public enum ErrorCode : Int {
        case NullRequest   = -1
        case MalformedURL  = -8
        case MalformedResponse = -11
    }

    public init(status: Int) {
        self.status = status
        self.headers = [:]
        self.data = nil
    }

    public init(status: Int, headers: [AnyHashable:Any], data: Data?) {
        self.status = status
        self.headers = headers
        self.data = data
    }
}

public struct WebRequest {
    public var endpoint        : WebRequestEndpoint = DefaultEndpoint(.GET, nil)
    public var headers         : [String:String]? = nil
    public var urlParameters   : [String:String]? = nil
    public var bodyParameters  : [String:Any]? = nil
    public var bodyData        : Data? = nil
    public var delivery        : WebRequestDelivery?   = nil
    public var completion      : ((WebResult, WebRequest) -> ())? = nil

    public enum Method : String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }

    public func execute() {
        delivery?.deliver(request:self)
    }

    public init() {}

    public init(endpoint: WebRequestEndpoint?,
                headers: [String:String]?,
                urlParameters: [String:String]?,
                bodyParameters: [String:Any]?,
                delivery: WebRequestDelivery?,
                completion: ((WebResult, WebRequest) -> ())?) {
        if (endpoint != nil) { self.endpoint = endpoint! }
        self.headers = headers
        self.urlParameters = urlParameters
        self.bodyParameters = bodyParameters
        self.delivery = delivery
        self.completion = completion
    }

    public init(endpoint: WebRequestEndpoint?,
                headers: [String:String]?,
                urlParameters: [String:String]?,
                bodyData: Data?,
                delivery: WebRequestDelivery?,
                completion: ((WebResult, WebRequest) -> ())?) {
        if (endpoint != nil) { self.endpoint = endpoint! }
        self.headers = headers
        self.urlParameters = urlParameters
        self.bodyData = bodyData
        self.delivery = delivery
        self.completion = completion
    }

    public init(urlString: String,
                method: WebRequest.Method,
                delivery: WebRequestDelivery?,
                completion: ((WebResult, WebRequest) -> ())?) {
        self.endpoint = DefaultEndpoint(method, urlString)
        self.delivery = delivery
        self.completion = completion
    }
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
