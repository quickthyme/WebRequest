import Foundation

public class BasicHTTPResultValidator: WebResultValidating {

    public init() {
    }

    public func isValid(_ result: WebRequest.Result) -> Bool {
        return 200...299 ~= result.status
    }

    public func isUnauthorized(_ result: WebRequest.Result) -> Bool {
        return 401 == result.status
    }
}
