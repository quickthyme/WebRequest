
import Foundation

open class HTTPWebRequestDelivery : NSObject, WebRequestDelivery {
    public typealias ErrorCode = WebRequest.Result.ErrorCode

    public let timeoutInterval: TimeInterval = 60.0

    open func deliver(request:WebRequest) throws {

        guard let url = self.constructURL(request: request) else {
            try self.complete(request: request, errorCode: .MalformedURL)
            return
        }

        // url session and headers
        let config = self.getURLSessionConfiguration()

        if let headers = self.getHeaders(request: request) {
            config.httpAdditionalHeaders = headers
        }

        let urlSession = self.getURLSession(configuration: config)

        // url request and method
        var urlRequest = self.getURLRequest(url: url)
        urlRequest.httpMethod = request.endpoint.method.rawValue

        // Body parameters
        if let bodyData = self.getBodyData(request: request) {
            urlRequest.httpBody = bodyData
        }

        // execute delivery
        try self.executeDelivery(request: request, urlSession: urlSession, urlRequest: urlRequest)
    }

    open func constructURL(request: WebRequest) -> URL? {

        if let urlString = request.endpoint.urlString,
            let url = URL(string: urlString) {
            return url
        }

        // base url/path
        var urlComponents = URLComponents(string: request.endpoint.urlBase) ?? URLComponents()

        let pathComponents = request.endpoint.urlPath.components(separatedBy: "?")
        urlComponents.path = pathComponents.first ?? request.endpoint.urlPath

        // url parameters
        if (pathComponents.count > 1) {
            let queryComponents = pathComponents[1].components(separatedBy: "&")
            urlComponents.queryItems =
                queryComponents
                    .map {
                        let keyVal = $0.components(separatedBy: "=")
                        return URLQueryItem(name: WebRequest.urlEncode(keyVal.first ?? ""),
                                            value: WebRequest.urlEncode(keyVal.last ?? "")) }
        }
        else if let urlParams  = request.urlParameters {
            urlComponents.queryItems =
                urlParams
                    .map { URLQueryItem(name: WebRequest.urlEncode($0.key),
                                        value: WebRequest.urlEncode($0.value)) }
        }

        // finalized url
        return urlComponents.url
    }

    open func getURLSessionConfiguration() -> URLSessionConfiguration {
        return URLSessionConfiguration.default
    }

    open func getURLSession(configuration: URLSessionConfiguration) -> URLSession {
        return URLSession(configuration: configuration)
    }

    open func getURLRequest(url:URL) -> URLRequest {
        return URLRequest(url: url,
                          cachePolicy: .reloadIgnoringCacheData,
                          timeoutInterval: timeoutInterval)
    }


    open func getHeaders(request: WebRequest) -> [String:String]? {
        return request.headers
    }


    open func getBodyData(request: WebRequest) -> Data? {
        if let explicitData = request.bodyData { return explicitData }
        guard let bodyParameters = request.bodyParameters else { return nil }
        var dataString : String = ""
        var separator = ""

        for (key, value) in bodyParameters {
            dataString.append(
                "\(separator)\(key)=\(WebRequest.urlFormEncode(value))"
            )
            separator = "&"
        }
        return (dataString != "") ? dataString.data(using: .utf8) : nil
    }


    open func executeDelivery(request: WebRequest,
                              urlSession: URLSession,
                              urlRequest: URLRequest) throws {
        let group = DispatchGroup()
        var taskData: Data?
        var taskResponse: HTTPURLResponse?

        let _ = {
            group.enter()
            let task = urlSession.dataTask(
                with: urlRequest,
                completionHandler: ({ (data, response, _) in
                    taskData = data
                    taskResponse = response as? HTTPURLResponse
                    group.leave()
                }))
            task.resume()
        }()

        let timeoutResult = group.wait(timeout: .now() + timeoutInterval)
        guard (timeoutResult != .timedOut) else {
            try complete(request: request, errorCode: .TimedOut)
            return
        }

        let taskStatus: Int = taskResponse?.statusCode
            ?? ErrorCode.MalformedResponse.rawValue

        try complete(request: request,
                     status: taskStatus,
                     headers: taskResponse?.allHeaderFields,
                     data: taskData)
    }


    open func complete(request: WebRequest, errorCode: ErrorCode) throws {
        try self.complete(request: request, status: errorCode.rawValue)
    }


    open func complete(request: WebRequest,
                       status: Int,
                       headers: [AnyHashable:Any]? = nil,
                       data:Data? = nil) throws {

        let headers = headers ?? [:]
        let result = WebRequest.Result(status: status, headers: headers, data: data)
        try request.completion?(result, request)
    }
}
