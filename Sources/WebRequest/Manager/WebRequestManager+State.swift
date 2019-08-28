import Foundation

public extension WebRequestManager {

    enum State {
        case ready
        case running
        case cancelled
        case completed
        case unauthorized
    }

    class Wrapper: Hashable {

        public typealias OnStateChange = (Wrapper) -> ()

        public let timestamp = Date().timeIntervalSinceReferenceDate

        public let originalRequest: WebRequest
        public var modifiedRequest: WebRequest

        public var result: WebRequest.Result? = nil

        public var state: State {
            didSet { onStateChange(self) }
        }

        public var onStateChange: OnStateChange

        public var attempts: Int = 0

        public let maxAttempts: Int = 2

        public init(request: WebRequest, onStateChange: @escaping OnStateChange) {
            self.state = .ready
            self.onStateChange = onStateChange
            self.originalRequest = request
            self.modifiedRequest = request
            self.modifiedRequest.completion = self.resultHandler
        }

        public func hash(into hasher: inout Hasher) {
            hasher.combine(timestamp)
        }

        public static func == (lhs: WebRequestManager.Wrapper, rhs: WebRequestManager.Wrapper) -> Bool {
            return lhs.timestamp == rhs.timestamp
        }

        public func execute() throws {
            attempts += 1
            try self.modifiedRequest.execute()
        }

        private lazy var resultHandler: WebRequest.Completion = { result, request in
            self.result = result
            self.state = self.getState(for: result, of: request)
        }

        private func getState(for result: WebRequest.Result, of request: WebRequest) -> State {
            switch true {
            case state == .cancelled:
                return .cancelled
            case (request.validator?.isUnauthorized(result) ?? false):
                return .unauthorized
            default:
                return .completed
            }
        }
    }
}
