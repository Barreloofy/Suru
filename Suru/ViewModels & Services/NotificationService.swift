//
//  NotificationService.swift
//  Suru
//
//  Created by Barreloofy on 10/26/24 at 4:03 PM.
//

import Foundation
import UserNotifications

actor NotificationService {
    static let center = UNUserNotificationCenter.current()
    
    static func notificationAuthorization() {
        Task {
            _ = try? await center.requestAuthorization(options: [.alert, .badge, .sound])
        }
    }
    
    static func createNotification(for item: SuruItem) {
        guard item.alert else { return }
        let content = UNMutableNotificationContent()
        content.title = item.content
        content.sound = UNNotificationSound.default
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    static func completionCheck(for item: SuruItem) {
        if item.completed {
            center.removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        } else {
            Task {
                let queue = await center.pendingNotificationRequests()
                let date = Date()
                if !queue.contains(where: { $0.identifier == item.id.uuidString}) && item.dueDate > date {
                    NotificationService.createNotification(for: item)
                }
            }
        }
    }
}
