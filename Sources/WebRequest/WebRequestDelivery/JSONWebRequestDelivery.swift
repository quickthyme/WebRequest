
import Foundation

open class JSONWebRequestDelivery : HTTPWebRequestDelivery {
    
    open override func getHeaders(request: WebRequest) -> [String:String]? {
        var headers : [String:String] = request.headers ?? [:]
        headers["Content-Type"] = "application/json"
        headers["Accept"] = "application/json"
        return headers
    }
    
    open override func getBodyData(request: WebRequest) -> Data? {
        if let explicitData = request.bodyData { return explicitData }
        guard let bodyParameters = request.bodyParameters,
            (JSONSerialization.isValidJSONObject(bodyParameters)),
            let data = try? JSONSerialization.data(withJSONObject: bodyParameters, options: [])
            else { return nil }
        return data
    }
}
