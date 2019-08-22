import Foundation

public class WebRequestManager: WebRequestManaging {

    typealias ErrorCode = WebRequest.Result.ErrorCode

    private let accessQueue: DispatchQueue = DispatchQueue(label: "WebRequestQueue.accessQueue",
                                                           qos: .background,
                                                           attributes: [],
                                                           autoreleaseFrequency: .inherit,
                                                           target: nil)

    private let execQueue: DispatchQueue = DispatchQueue(label: "WebRequestQueue.performQueue",
                                                         qos: .background,
                                                         attributes: [],
                                                         autoreleaseFrequency: .inherit,
                                                         target: nil)

    internal var requests: [WebRequest] = []

    internal var isBusy: Bool = false

    public let timeoutInterval: TimeInterval = 60.0

    public var sessionProvider: WebRequestSessionProviding! {
        didSet { sessionProvider?.delegate = self }
    }

    public var applySession: SessionApplier!

    public static let shared = WebRequestManager()

    private init() { /**/ }

    public init(sessionProvider: WebRequestSessionProviding?,
                applySession: SessionApplier?) {
        set(sessionProvider: sessionProvider,
            applySession: applySession)
    }

    public func set(sessionProvider: WebRequestSessionProviding?,
                    applySession: SessionApplier?) {
        self.sessionProvider = sessionProvider
        self.applySession = applySession
    }
}

public extension WebRequestManager /*: WebRequestManaging */ {

    func begin(request: WebRequest) throws {
        let originalRequest = request
        var modifiedRequest = request

        var pendingResult: WebRequest.Result? = nil
        var refreshAttemptsMade: Int = 0

        let group = DispatchGroup()
        group.enter()

        modifiedRequest.completion = { result, request in
            if let validator = request.validator,
                validator.isUnauthorized(result),
                refreshAttemptsMade < 1 {
                refreshAttemptsMade += 1
                self.sessionProvider.refresh()
            } else {
                pendingResult = result
                group.leave()
            }
        }

        enqueue(modifiedRequest)
        begin()

        let timeoutResult = group.wait(timeout: .now() + timeoutInterval)

        if (timeoutResult != .timedOut),
            let actualResult = pendingResult {
            try originalRequest.completion?(actualResult, originalRequest)
            self.removeNext()
            self.beginNext()
            
        } else {
            let timeoutResult = WebRequest.Result(status: ErrorCode.TimedOut.rawValue)
            try originalRequest.completion?(timeoutResult, originalRequest)
            isBusy = false
        }
    }

    func flush() {
        accessQueue.sync {
            self.requests = []
            self.isBusy = false
        }
    }
}

private extension WebRequestManager {

    func begin() {
        guard (!isBusy) else { return }
        self.isBusy = true
        beginNext()
    }

    func beginNext() {
        execQueue.async {
            self.isBusy = !( self.runNext() )
        }
    }

    func runNext() -> Bool {
        guard let request = getNext() else { return false }

        guard let session = self.sessionProvider?.current else {
            failNext(usingStatus: 401)
            return false
        }

        let readyRequest = applySession(request, session)
        try? readyRequest.execute()

        return true
    }

    func getNext() -> WebRequest? {
        var request: WebRequest?
        accessQueue.sync {
            request = self.requests.first
        }
        return request
    }

    func removeNext() {
        accessQueue.sync {
            if !(self.requests.isEmpty) {
                _ = self.requests.removeFirst()
            }
        }
    }

    func failNext(usingStatus status: Int) {
        guard let request = getNext() else { return }
        try? request.completion?(WebRequest.Result(status: status), request)
    }

    func enqueue(_ request: WebRequest) {
        accessQueue.sync {
            self.requests.append(request)
        }
    }
}

extension WebRequestManager: WebRequestSessionProvidingDelegate {

    public func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didRefreshSession: WebRequestSession) {
        beginNext()
    }

    public func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didFailToRefresh: Void) {
        failNext(usingStatus: 401)
        flush()
    }
}
