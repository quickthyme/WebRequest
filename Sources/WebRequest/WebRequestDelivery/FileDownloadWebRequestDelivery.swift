
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
        doFileManagement(target: downloadURL, destination: targetURL)
        fulfillCompletion(downloadTask: downloadTask)
    }
    
    func fulfillCompletion(downloadTask: URLSessionDownloadTask) {
        let request = self.webRequest!
        let response = downloadTask.response as? HTTPURLResponse
        let status : Int = response?.statusCode ?? WebRequest.Result.ErrorCode.MalformedResponse.rawValue
        let headers = response?.allHeaderFields ?? [:]
        try? self.complete(request: request, status: status, headers: headers)
        self.webRequest = nil
    }
    
    func doFileManagement(target: URL, destination: URL) {
        if FileManager.default.fileExists(atPath: target.path) {
            if FileManager.default.fileExists(atPath: destination.path) {
                do { try FileManager.default.removeItem(at: destination) }
                catch {print(error)}
            }
            do { try FileManager.default.moveItem(at: target, to: destination) }
            catch { print(error) }
        }
    }
    
    open func urlSession(_ session: URLSession, didBecomeInvalidWithError error: Error?) {
        if let error = error { print("\(#function) - \(error)") }
        self.webRequest = nil
    }
}
