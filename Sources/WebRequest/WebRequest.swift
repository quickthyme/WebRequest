import Foundation

public protocol WebRequestDelivery {
    func deliver(request:WebRequest) throws
}

public struct WebRequest {
    public typealias Completion = (Result, WebRequest) throws -> ()
    public typealias DataReceived = (Result, WebRequest, Int, URL) throws -> ()

    public var endpoint        : WebRequestEndpoint = DefaultEndpoint(.GET, nil)
    public var headers         : [String:String]? = nil
    public var urlParameters   : [String:String]? = nil
    public var bodyParameters  : [String:Any]? = nil
    public var bodyData        : Data? = nil
    public var delivery        : WebRequestDelivery?   = nil
    public var completion      : Completion? = nil
    public var onDataReceived  : DataReceived? = nil

    public enum Method : String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }

    public static var isDisabled: Bool = false

    public func execute() throws {
        if !WebRequest.isDisabled {
            try delivery?.deliver(request:self)
        }
    }

    public init() {}

    public init(endpoint: WebRequestEndpoint?,
                headers: [String:String]?,
                urlParameters: [String:String]?,
                bodyParameters: [String:Any]?,
                delivery: WebRequestDelivery?,
                completion: Completion?) {
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
                completion: Completion?) {
        if (endpoint != nil) { self.endpoint = endpoint! }
        self.headers = headers
        self.urlParameters = urlParameters
        self.bodyData = bodyData
        self.delivery = delivery
        self.completion = completion
    }
    
    public init(endpoint: WebRequestEndpoint?,
                headers: [String:String]?,
                urlParameters: [String:String]?,
                delivery: FileDownloadWebRequestDelivery?,
                onDataReceived: DataReceived?) { //progress type completion  // Double
        if (endpoint != nil) { self.endpoint = endpoint! }
        self.headers = headers
        self.urlParameters = urlParameters
        self.delivery = delivery
        self.onDataReceived = onDataReceived
    }
    
    public init(urlString: String,
                method: WebRequest.Method,
                delivery: ProgressFileDownloadWebRequestDelivery?,
                onDataReceived: DataReceived?) { //progress type completion  // Double
        self.endpoint = DefaultEndpoint(method, urlString)
        self.delivery = delivery
        self.onDataReceived = onDataReceived
    }

    public init(urlString: String,
                method: WebRequest.Method,
                delivery: WebRequestDelivery?,
                completion: Completion?) {
        self.endpoint = DefaultEndpoint(method, urlString)
        self.delivery = delivery
        self.completion = completion
    }
}
