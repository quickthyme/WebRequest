
import Foundation

class MockURLSession : URLSession {
    
    var testConfiguration : URLSessionConfiguration?
    var testDelegate : URLSessionDelegate?
    var testDelegateQueue : OperationQueue?
    
    var taskCompletion : [MockURLSessionDataTask : (Data?, URLResponse?, Error?) -> Void] = [:]
    
    var mockData     : Data?
    var mockResponse : URLResponse?
    var mockError    : Error?
    
    
    required init(configuration: URLSessionConfiguration) {
        self.testConfiguration = configuration
    }
    
    required init(configuration: URLSessionConfiguration, delegate: URLSessionDelegate?, delegateQueue: OperationQueue?) {
        self.testConfiguration = configuration
        self.testDelegate = delegate
        self.testDelegateQueue = delegateQueue
    }
    
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let task = MockURLSessionDataTask(mockSession: self, url: url)
        taskCompletion[task] = completionHandler
        return task
    }
    
    override func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        let url = request.url
        return self.dataTask(with: url!, completionHandler: completionHandler)
    }
    
    override func downloadTask(with url: URL) -> URLSessionDownloadTask {
        let task = MockURLSessionDownloadTask(mockSession: self, url: url)
        return task
    }
    
    override func downloadTask(with request: URLRequest) -> URLSessionDownloadTask {
        let url = request.url
        return self.downloadTask(with: url!)
    }
    
    override func finishTasksAndInvalidate() {
    }
    
    override func invalidateAndCancel() {
    }
    
}


class MockURLSessionDataTask : URLSessionDataTask {
    
    private weak var mockSession : MockURLSession?;  private let mockURL : URL
    var mockData     : Data?        { return self.mockSession?.mockData }
    var mockResponse : URLResponse? { return self.mockSession?.mockResponse }
    var mockError    : Error?       { return self.mockSession?.mockError }
    
    init(mockSession: MockURLSession, url:URL) {
        self.mockSession = mockSession
        self.mockURL = url
    }
    
    override func resume() {
        if let completion = self.mockSession?.taskCompletion[self] {
            completion(self.mockData, mockResponse, mockError)
        }
    }
}


class MockURLSessionDownloadTask : URLSessionDownloadTask {
    
    private weak var mockSession : MockURLSession?;  private let mockURL : URL
    var mockData     : Data?        { return self.mockSession?.mockData }
    var mockResponse : URLResponse? { return self.mockSession?.mockResponse }
    var mockError    : Error?       { return self.mockSession?.mockError }
    
    override var response: URLResponse? { return self.mockResponse }
    
    init(mockSession: MockURLSession, url:URL) {
        self.mockSession = mockSession
        self.mockURL = url
    }
    
    
    override func resume() {
        
        if let session = self.mockSession,
            let delegate = session.testDelegate as? URLSessionDownloadDelegate {
            let mockDestination = URL(fileURLWithPath: "")
            delegate.urlSession(session, downloadTask: self, didFinishDownloadingTo: mockDestination)
        }
    }
}
