
import Foundation

class MultipartFormUploadWebRequestDelivery : HTTPWebRequestDelivery {
    
    lazy var boundary : String = self.generateBoundary()
    var filename : String?
    var filetype : String?
    
    enum FileTypes : String {
        case imageJPEG = "image/jpeg"
        case imagePNG  = "image/png"
    }
    
    override func getHeaders(request: WebRequest) -> [String:String]? {
        var headers : [String:String] = request.headers ?? [:]
        headers["Content-Type"] = "multipart/form-data; boundary=\(boundary)"
        return headers
    }
    
    override func getBodyData(request: WebRequest) -> Data? {
        guard let bodyData = request.bodyData else { return nil }
        
        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        
        let filename = self.filename ?? "userfile"
        body.append("Content-Disposition: form-data; name=\"\(filename)\"; filename=\"\(filename)\"\r\n".data(using: .utf8)!)
        
        if let filetype = self.filetype {
            body.append("Content-Type: \(filetype)\r\n".data(using: .utf8)!)
        }
        
        body.append("Content-Transfer-Encoding: binary\r\n\r\n".data(using: .utf8)!)
        body.append(bodyData)
        body.append("\r\n".data(using: .utf8)!)
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        return body
    }
    
    private func generateBoundary() -> String {
        return UUID().uuidString.trimmingCharacters(in: CharacterSet(charactersIn: "-"))
    }
}
