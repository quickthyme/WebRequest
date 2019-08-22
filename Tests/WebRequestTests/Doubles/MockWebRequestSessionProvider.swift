import Foundation
import WebRequest

class MockWebRequestSessionProvider: WebRequestSessionProviding {

    var delegate: WebRequestSessionProvidingDelegate?

    var current: WebRequestSession?

    var refreshSuccessSession: WebRequestSession? = nil

    var timesCalled_refresh: Int = 0
    func refresh() {
        timesCalled_refresh += 1
        if let session = refreshSuccessSession {
            refreshSuccessSession = session
            delegate?.sessionProvider(self, didRefreshSession: session)
        } else {
            delegate?.sessionProvider(self, didFailToRefresh: ())
        }
    }
}
