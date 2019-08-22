import Foundation

public protocol WebRequestManaging {

    typealias SessionApplier = (WebRequest, WebRequestSession) -> (WebRequest)

    var  sessionProvider: WebRequestSessionProviding! { get set }

    var  applySession: SessionApplier! { get set }

    func begin(request: WebRequest) throws

    func flush()
}
