import Foundation

public protocol WebRequestSessionProviding: class {
    var delegate: WebRequestSessionProvidingDelegate? { get set }
    var current: WebRequestSession? { get }
    func refresh()
}

public protocol WebRequestSessionProvidingDelegate: class {
    func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didRefreshSession: WebRequestSession)
    func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didFailToRefresh: Void)
}
