import Foundation

public enum AirframeRefreshNotification {
    public static let message = "refresh"
    public static let name = Notification.Name("com.airframe.agilecockpit.refresh")

    public static func postRefresh() {
        #if os(macOS)
        DistributedNotificationCenter.default().post(name: name, object: message)
        #else
        NotificationCenter.default.post(name: name, object: message)
        #endif
    }
}
