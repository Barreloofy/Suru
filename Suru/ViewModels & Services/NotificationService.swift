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
    static var notificationPermission = false
    
    static func notificationAuthorization() {
        Task {
            guard let permissionResult = try? await center.requestAuthorization(options: [.alert, .badge, .sound]) else { return }
            notificationPermission = permissionResult
        }
    }
    
    static func setDefaultAlertValue(_ defaultAlertValue: inout Bool) {
        if !notificationPermission {
            defaultAlertValue = false
        }
    }
    
    static func clearNotifications() {
        center.setBadgeCount(0)
        center.removeAllDeliveredNotifications()
    }
    
    static func createNotification(for item: SuruItem) {
        guard item.alert, item.dueDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.title = item.content
        content.sound = UNNotificationSound.default
        content.badge = 1
        let dateComponents = configureDateComponents(for: item.dueDate, with: item.repeatFrequency)
        let shouldRepeat = item.repeatFrequency == .Never ? false : true
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: shouldRepeat)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        center.add(request)
    }
    
    static func configureDateComponents(for date: Date, with repeatValue: Frequency) -> DateComponents {
        let calendar = Calendar.current
        var dateComponents: DateComponents
        switch repeatValue {
        case .Never:
            return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        case .Hourly:
            dateComponents = calendar.dateComponents([.hour, .minute], from: date)
            dateComponents.second = 0
            return dateComponents
        case .Daily:
            dateComponents = calendar.dateComponents([.hour, .minute], from: date)
            dateComponents.second = 0
            return dateComponents
        case .Weekly:
            dateComponents = calendar.dateComponents([.weekday, .hour, .minute], from: date)
            dateComponents.second = 0
            return dateComponents
        case .Monthly:
            dateComponents = calendar.dateComponents([.day, .hour, .minute], from: date)
            dateComponents.second = 0
            return dateComponents
        case .Yearly:
            dateComponents = calendar.dateComponents([.month, .day, .hour, .minute], from: date)
            dateComponents.second = 0
            return dateComponents
        }
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

import SwiftUI
extension NotificationService {
    static func alertText() -> some View {
        if !NotificationService.notificationPermission {
            AnyView(
                Text("Notifications are turned off")
                    .listRowBackground(Color.autumnOrange.opacity(0.75))
                    .listRowSeparator(.hidden)
                    .fontWeight(.light)
            )
        } else {
            AnyView(
                EmptyView()
            )
        }
    }
}
