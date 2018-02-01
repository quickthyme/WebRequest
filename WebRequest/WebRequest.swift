
import Foundation

protocol WebRequestEndpoint {
    var method  : WebRequest.Method { get }
    var urlBase : String { get }
    var urlPath : String { get }
}

protocol WebRequestDelivery {
    func deliver(request:WebRequest)
}

struct WebResult {
    var status : Int = -1
    var headers: [AnyHashable:Any]
    var data   : Data?
    
    enum ErrorCode : Int {
        case NullRequest   = -1
        case MalformedURL  = -8
        case MalformedResponse = -11
    }
}

struct WebRequest {
    
    var urlString       : String? = nil
    var endpoint        : WebRequestEndpoint = NullEndpoint(method: .GET)
    var headers         : [String:String]? = nil
    var urlParameters   : [String:String]? = nil
    var bodyParameters  : [String:Any]? = nil
    var bodyData        : Data? = nil
    var delivery        : WebRequestDelivery?   = nil
    var completion      : ((WebResult, WebRequest) -> ())? = nil
    
    enum Method : String {
        case OPTIONS, GET, HEAD, POST, PUT, PATCH, DELETE, TRACE, CONNECT
    }
    
    func execute() {
        delivery?.deliver(request:self)
    }
    
    init() {}
    
    init(endpoint: WebRequestEndpoint?,
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
    
    init(endpoint: WebRequestEndpoint?,
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
    
    init(urlString: String,
         method: WebRequest.Method,
         delivery: WebRequestDelivery?,
         completion: ((WebResult, WebRequest) -> ())?) {
        self.urlString = urlString
        self.delivery = delivery
        self.completion = completion
        self.endpoint = NullEndpoint(method: method)
    }
    
}

fileprivate struct NullEndpoint : WebRequestEndpoint {
    let method  : WebRequest.Method
    let urlBase = ""
    let urlPath = ""
    init(method: WebRequest.Method) {
        self.method = method
    }
}
