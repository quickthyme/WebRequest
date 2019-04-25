import Foundation

extension WebRequest {
    public struct Result {
        public var status : Int = -1
        public var headers: [AnyHashable:Any]
        public var data   : Data?

        public enum ErrorCode : Int {
            case NullRequest   = -1
            case MalformedURL  = -8
            case MalformedResponse = -11
            case TimedOut = -12
        }

        public init(status: Int) {
            self.status = status
            self.headers = [:]
            self.data = nil
        }

        public init(status: Int, headers: [AnyHashable:Any], data: Data?) {
            self.status = status
            self.headers = headers
            self.data = data
        }
    }
}
