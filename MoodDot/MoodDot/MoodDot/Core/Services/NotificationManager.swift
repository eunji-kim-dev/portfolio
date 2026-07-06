import Foundation
import UserNotifications

enum NotificationManager {
    private static let id = "mooddot.daily"

    /// 권한 요청 + (허용되면) 스케줄 등록
    static func requestAndScheduleDaily(hour: Int, minute: Int) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { ok, err in
            if let err { print("🔴 notif auth error:", err) }
            guard ok else {
                print("🔴 notif permission denied")
                return
            }
            scheduleDaily(hour: hour, minute: minute)
        }
    }

    /// 매일 반복 알림 등록
    static func scheduleDaily(hour: Int, minute: Int) {
        cancelDaily()

        let content = UNMutableNotificationContent()
        content.title = "MoodDot"
        content.body = "오늘 감정 기록할 시간."
        content.sound = .default

        var comps = DateComponents()
        comps.hour = hour
        comps.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: true)
        let req = UNNotificationRequest(identifier: id, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(req) { err in
            if let err { print("🔴 notif schedule error:", err) }
            else { print("✅ notif scheduled:", hour, minute) }
        }
    }

    static func cancelDaily() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [id])
    }
}
