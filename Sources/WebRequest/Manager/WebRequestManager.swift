import Foundation

internal protocol WRNotificationCenterInterface {
    func post(_ notification: Notification)
}
extension NotificationCenter: WRNotificationCenterInterface {}

public class WebRequestManager: WebRequestManaging {

    public typealias ErrorCode = WebRequest.Result.ErrorCode

    internal var UnauthorizedResponseNotification: Notification {
        return Notification(name: WebRequestUnauthorizedResponseNotification, object: nil, userInfo: nil)
    }

    private let accessQueue: DispatchQueue = DispatchQueue(label: "WebRequestQueue.accessQueue",
                                                           qos: .background,
                                                           attributes: [],
                                                           autoreleaseFrequency: .inherit,
                                                           target: nil)

    private let execQueue: DispatchQueue = DispatchQueue(label: "WebRequestQueue.performQueue",
                                                         qos: .background,
                                                         attributes: .concurrent,
                                                         autoreleaseFrequency: .inherit,
                                                         target: nil)

    internal var requests: Set<Wrapper> = Set<Wrapper>()

    public var timeoutInterval: TimeInterval = 60.0

    public var lastRefresh: TimeInterval = 0.0

    private let refreshThreshold: TimeInterval = 120.0

    private var isRefreshing: Bool = false

    public var sessionProvider: WebRequestSessionProviding! {
        didSet { sessionProvider?.delegate = self }
    }

    public var applySession: SessionApplier!

    internal lazy var notificationCenter: WRNotificationCenterInterface = NotificationCenter.default

    public static let shared = WebRequestManager()

    private init() { /**/ }

    public init(sessionProvider: WebRequestSessionProviding?,
                applySession: SessionApplier?,
                timeoutInterval: TimeInterval = 60.0,
                lastRefresh: TimeInterval = 0.0) {
        set(sessionProvider: sessionProvider,
            applySession: applySession,
            timeoutInterval: timeoutInterval,
            lastRefresh: lastRefresh)
    }

    public func set(sessionProvider: WebRequestSessionProviding?,
                    applySession: SessionApplier?,
                    timeoutInterval: TimeInterval = 60.0,
                    lastRefresh: TimeInterval = 0.0) {
        self.sessionProvider = sessionProvider
        self.applySession = applySession
        self.timeoutInterval = timeoutInterval
        self.lastRefresh = lastRefresh
    }

    public func begin(request: WebRequest) throws {
        let group = DispatchGroup()
        group.enter()

        let wrapper = Wrapper(request: request,
                              onStateChange: getOnStateChange(in: group))
        stage(wrapper)
        begin()
        let timeoutResult = group.wait(timeout: .now() + timeoutInterval)
        try end(wrapper, timeoutResult)
    }
}

private extension WebRequestManager {

    func getOnStateChange(in group: DispatchGroup) -> Wrapper.OnStateChange {
        return { wrapper in
            switch wrapper.state {

            case .ready:
                break

            case .running:
                break

            case .unauthorized:
                switch (true) {

                case (self.isRefreshing):
                    break

                case (self.shouldRefresh(since: wrapper.timestamp)):
                    self.performRefresh()

                case (wrapper.attempts < wrapper.maxAttempts):
                    self.begin()

                default:
                    group.leave()
                }

            case .cancelled:
                group.leave()

            case .completed:
                group.leave()
            }
        }
    }

    func stage(_ wrapper: Wrapper) {
        accessQueue.sync {
            _ = self.requests.insert(wrapper)
        }
    }

    func begin() {
        guard (!isRefreshing) else { return }
        accessQueue.sync {
            let readyRequests = self.requests
                .filter { $0.state == .ready || $0.state == .unauthorized }

            guard let session = self.sessionProvider?.current else {
                if let anyRequest = readyRequests.first?.originalRequest {
                    self.fail(request: anyRequest, withStatus: 401)
                }
                for wrapper in readyRequests { wrapper.state = .cancelled }
                notificationCenter.post(UnauthorizedResponseNotification)
                return
            }

            for wrapper in readyRequests {
                wrapper.state = .running
                wrapper.modifiedRequest = applySession(wrapper.modifiedRequest, session)
                execQueue.async {
                    try? wrapper.execute()
                }
            }
        }
    }

    func end(_ wrapper: Wrapper, _ timeoutResult: DispatchTimeoutResult) throws {
        self.remove(wrapper)

        guard (wrapper.state != .cancelled) else { return }

        guard (timeoutResult != .timedOut),
            let actualResult = wrapper.result else {
                let timeoutResult = WebRequest.Result(status: ErrorCode.TimedOut.rawValue)
                try wrapper.originalRequest.completion?(timeoutResult, wrapper.originalRequest)
                return
        }

        try wrapper.originalRequest.completion?(actualResult, wrapper.originalRequest)

        if wrapper.state == .unauthorized {
            notificationCenter.post(UnauthorizedResponseNotification)
        }
    }

    func shouldRefresh(since timestamp: TimeInterval) -> Bool {
        return timestamp > (lastRefresh + refreshThreshold)
    }

    func performRefresh() {
        isRefreshing = true
        sessionProvider.refresh()
    }

    func remove(_ wrapper: Wrapper) {
        accessQueue.sync {
            if !(self.requests.isEmpty) {
                _ = self.requests.remove(wrapper)
            }
        }
    }

    func fail(request: WebRequest, withStatus status: Int) {
        try? request.completion?(WebRequest.Result(status: status), request)
    }
}

extension WebRequestManager: WebRequestSessionProvidingDelegate {

    public func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didRefreshSession: WebRequestSession) {
        lastRefresh = Date().timeIntervalSinceReferenceDate
        isRefreshing = false
        begin()
    }

    public func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didFailToRefresh: Void) {
        lastRefresh = Date().timeIntervalSinceReferenceDate
        isRefreshing = false
        begin()
    }
}
