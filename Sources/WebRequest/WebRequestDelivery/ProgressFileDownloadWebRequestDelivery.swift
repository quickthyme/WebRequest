import Foundation

open class ProgressFileDownloadWebRequestDelivery: FileDownloadWebRequestDelivery {

    let divisor = pow(10.0, Double(2))
    let ONE_HUDRED_PERCENT = 100
    let ZERO_PERCENT = 0
    
    public func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        if(totalBytesWritten < totalBytesExpectedToWrite) {
            let percentageComplete = Int((((Double(Float(totalBytesWritten) / Float(totalBytesExpectedToWrite))) * divisor).rounded(.down) / divisor) * 100);
            let status = getStatus(downloadTask: downloadTask)
            fulfillDataReceived(status: status, percentComplete: percentageComplete)
        }
    }

    open override func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        let status = getStatus(downloadTask: downloadTask)
        
        if status != 200 {
           fulfillDataReceived(status: status, percentComplete: ZERO_PERCENT)
        } else {
            let downloadURL = location
            doFileManagement(target: downloadURL, destination: targetURL)
            fulfillDataReceived(status: status, percentComplete: ONE_HUDRED_PERCENT)
        }

         self.webRequest = nil
    }
    
    func fulfillDataReceived(status: Int, percentComplete: Int) {
        let request = self.webRequest!
        try? self.onDataReceived(request: request, status: status, percentComplete: percentComplete, target: targetURL)
    }
    
    func getStatus(downloadTask: URLSessionDownloadTask) -> Int {
        let response = downloadTask.response as? HTTPURLResponse
        return response?.statusCode ?? WebRequest.Result.ErrorCode.MalformedResponse.rawValue
    }
    
}
