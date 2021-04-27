import Foundation

public protocol WebRequestSessionProviding: AnyObject {
    var delegate: WebRequestSessionProvidingDelegate? { get set }
    var current: WebRequestSession? { get }
    func refresh()
}

public protocol WebRequestSessionProvidingDelegate: AnyObject {
    func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didRefreshSession: WebRequestSession)
    func sessionProvider(_ sessionProvider: WebRequestSessionProviding, didFailToRefresh: Void)
}
