import Foundation
@testable import WebRequest

class MockNotificationCenter: WRNotificationCenterInterface {

    var didPost: Bool = false
    var postedNotificationName: Notification.Name? = nil

    func post(_ notification: Notification) {
        didPost = true
        postedNotificationName = notification.name
    }
}
