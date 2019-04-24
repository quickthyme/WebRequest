
import Foundation

open class FileDownloadWebRequestDelivery : HTTPWebRequestDelivery, URLSessionDownloadDelegate {
    
    open var targetURL : URL
    open var webRequest : WebRequest?
    
    public required init(targetURL: URL) {
        self.targetURL = targetURL
        super.init()
    }
    
    public convenience init(targetPath: String) {
        self.init(targetURL: URL(fileURLWithPath: targetPath))
    }
    
    open override func getURLSession(configuration: URLSessionConfiguration) -> URLSession {
        let session = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        return session
    }
    
    open override func executeDelivery(request: WebRequest, urlSession: URLSession, urlRequest: URLRequest) throws {
        self.webRequest = request
        let task = urlSession.downloadTask(with: urlRequest)
        task.resume()
        urlSession.finishTasksAndInvalidate()
    }
    
    open func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let downloadURL = location
        
        if FileManager.default.fileExists(atPath: downloadURL.path) {
            do { try FileManager.default.moveItem(at: downloadURL, to: targetURL) }
            catch _ {  }
        }
        
        let request = self.webRequest!
        let response = downloadTask.response as? HTTPURLResponse
        let status : Int = response?.statusCode ?? WebRequest.Result.ErrorCode.MalformedResponse.rawValue
        let headers = response?.allHeaderFields ?? [:]
        try? self.complete(request: request, status: status, headers: headers)
        self.webRequest = nil
    }
    
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error { print("\(#function) - \(error)") }
        self.webRequest = nil
    }
}
