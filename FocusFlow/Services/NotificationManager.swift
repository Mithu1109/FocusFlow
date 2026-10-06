//
//  NotificationManager.swift
//  FocusFlow
//
//  Created for FocusFlow Smart Study Planner.
//

import Foundation
import UserNotifications
import Combine

final class NotificationManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationManager()
    
    @Published var isAuthorized: Bool = false
    
    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
        checkAuthorization()
    }
    
    func checkAuthorization() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                self.isAuthorized = (settings.authorizationStatus == .authorized)
            }
        }
    }
    
    func requestAuthorization(completion: @escaping (Bool) -> Void = { _ in }) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            DispatchQueue.main.async {
                self.isAuthorized = granted
                completion(granted)
            }
        }
    }
    
    // MARK: - Pomodoro Completion Notification
    func scheduleTimerCompletionNotification(subject: String, minutes: Int) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete! 🎉"
        content.body = "Great work! You finished your \(minutes)-minute study session for \(subject)."
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        let request = UNNotificationRequest(identifier: "timer_complete_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - High Priority Task Reminder
    func scheduleTaskDueReminder(for task: TaskItem) {
        guard isAuthorized, let due = task.dueDate, !task.isCompleted else { return }
        
        // Reminder 1 hour before due date
        let reminderDate = due.addingTimeInterval(-3600)
        guard reminderDate > Date() else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "⚠️ High Priority Task Due Soon"
        content.body = "\"\(task.unwrappedTitle)\" for \(task.unwrappedSubject) is due in 1 hour."
        content.sound = .default
        
        let components = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: reminderDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        let request = UNNotificationRequest(identifier: "task_\(task.unwrappedId.uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Smart Study Habit Reminder
    func scheduleStudyReminder(hour: Int, minute: Int = 0) {
        guard isAuthorized else { return }
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Focused Study 💡"
        content.body = "Your peak productivity window has started. Jump into FocusFlow to stay on track!"
        content.sound = .default
        
        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: "daily_study_reminder", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - Instant Test Notification
    func sendTestNotification() {
        guard isAuthorized else {
            requestAuthorization { granted in
                if granted {
                    self.sendTestNotification()
                }
            }
            return
        }
        
        let content = UNMutableNotificationContent()
        content.title = "FocusFlow Notification Test 🔔"
        content.body = "Notifications are active and ready to keep you focused!"
        content.sound = .default
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 2, repeats: false)
        let request = UNNotificationRequest(identifier: "test_notification_\(UUID().uuidString)", content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request)
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound])
    }
}
