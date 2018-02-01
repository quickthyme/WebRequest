
import Foundation

class FileDownloadWebRequestDelivery : HTTPWebRequestDelivery {
    
    var targetURL : URL
    var webRequest : WebRequest?
    
    required init(targetURL: URL) {
        self.targetURL = targetURL
        super.init()
    }
    
    convenience init(targetPath: String) {
        self.init(targetURL: URL(fileURLWithPath: targetPath))
    }
    
    override func getURLSession(configuration: URLSessionConfiguration) -> URLSession {
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    override func executeDelivery(request: WebRequest, urlSession: URLSession, urlRequest: URLRequest) {
        self.webRequest = request
        let task = urlSession.downloadTask(with: urlRequest)
        task.resume()
        urlSession.finishTasksAndInvalidate()
    }
    
}

extension FileDownloadWebRequestDelivery : URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let downloadURL = location
        
        if FileManager.default.fileExists(atPath: downloadURL.path) {
            do { try FileManager.default.moveItem(at: downloadURL, to: targetURL) }
            catch _ {  }
        }
        
        let request = self.webRequest!
        let response = downloadTask.response as? HTTPURLResponse
        let status : Int = response?.statusCode ?? WebResult.ErrorCode.MalformedResponse.rawValue
        let headers = response?.allHeaderFields ?? [:]
        self.send(completion: request.completion, request: request, status: status, headers: headers)
        self.webRequest = nil
    }
    
    func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error { print("\(#function) - \(error)") }
        self.webRequest = nil
    }
}
