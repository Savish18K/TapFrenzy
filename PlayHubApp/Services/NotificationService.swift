import Foundation
import UserNotifications

class NotificationService {
    static let shared = NotificationService()
    
    private init() {}
    
    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error = error {
                print("Notification permission error: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleDailyNotification(at hour: Int, minute: Int, type: String = "Random") {
        cancelAll()
        
        let content = UNMutableNotificationContent()
        content.title = "PlayHubApp"
        
        switch type {
        case "Tap Frenzy":
            content.body = "It's Tap Frenzy time! 👆 Tap as fast as you can to beat your high score!"
        case "Light It Up":
            content.body = "Time to Light It Up! 💡 React fast and beat your high score!"
        case "Quiz Rush":
            content.body = "Quiz Rush time! 🧠 Put your knowledge to the test and get 10/10!"
        default:
            content.body = "It's time to play! Can you beat your high score?"
        }
        
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "dailyReminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            } else {
                print("Daily notification (\(type)) scheduled for \(hour):\(String(format: "%02d", minute))")
            }
        }
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
