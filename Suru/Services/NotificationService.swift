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
    
    private init() {}
    
    static func notificationAuthorization() {
        Task {
            guard let permissionResult = try? await center.requestAuthorization(options: [.alert, .sound, .badge]) else { return }
            notificationPermission = permissionResult
        }
    }
    
    static func setDefaultAlertValue(_ defaultAlertValue: inout Bool) {
        guard !notificationPermission else { return }
        defaultAlertValue = false
    }
    
    static func cleanup() {
        center.setBadgeCount(0)
        center.removeAllDeliveredNotifications()
    }
    
    static func badgeUpdater() async {
        let pendingNotifications = await center.pendingNotificationRequests().sorted {
            guard let lhsTrigger = $0.trigger as? UNCalendarNotificationTrigger, let lhsTriggerDate = lhsTrigger.nextTriggerDate() else { return false }
            guard let rhsTrigger = $1.trigger as? UNCalendarNotificationTrigger, let rhsTriggerDate = rhsTrigger.nextTriggerDate() else { return false }
            return lhsTriggerDate < rhsTriggerDate
        }
        var count = 1
        
        pendingNotifications.forEach {
            badgeUpdater($0, count)
            count += 1
        }
    }
    
    static private func badgeUpdater(_ request: UNNotificationRequest, _ count: Int) {
        let id = request.identifier
        let conten = request.content
        let trigger = request.trigger
        
        let updatedContent = UNMutableNotificationContent()
        updatedContent.title = conten.title
        updatedContent.sound = conten.sound
        updatedContent.badge = NSNumber(value: count)
        
        let updatedRequest = UNNotificationRequest(identifier: id, content: updatedContent, trigger: trigger)
        center.add(updatedRequest)
    }
    
    static func configureDateComponents(for date: Date, with repeatValue: Frequency) -> DateComponents {
        let calendar = Calendar.current
        switch repeatValue {
            case .Never:
                return calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
            case .Yearly:
                return calendar.dateComponents([.month, .day, .hour, .minute], from: date)
            case .Monthly:
                return calendar.dateComponents([.day, .hour, .minute], from: date)
            case .Weekly:
                return calendar.dateComponents([.weekday, .hour, .minute], from: date)
            case .Daily:
                return calendar.dateComponents([.hour, .minute], from: date)
            case .Hourly:
                return calendar.dateComponents([.minute], from: date)
        }
    }
    
    static func configureBadge(_ dueDate: Date) async -> NSNumber {
        let pendingNotifications = await center.pendingNotificationRequests()
        var count = 1
        pendingNotifications.forEach { notification in
            guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else { return }
            guard let triggerDate = trigger.nextTriggerDate() else { return }
            if dueDate > triggerDate { count += 1 }
        }
        return NSNumber(value: count)
    }
    
    static func createNotification(for item: SuruItem) async {
        guard item.alert, item.dueDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.body = item.content
        content.sound = UNNotificationSound.default
        content.badge = await configureBadge(item.dueDate)
        let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.dueDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        try? await center.add(request)
    }
    
    static func createRepeatingNotification(for item: SuruItem) async {
        let content = UNMutableNotificationContent()
        content.body = item.content
        content.sound = UNNotificationSound.default
        content.badge = await configureBadge(item.dueDate)
        let dateComponents = configureDateComponents(for: item.dueDate, with: item.repeatFrequency)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        try? await center.add(request)
    }
    
    static func completionCheck(for item: SuruItem) {
        guard !item.completed else {
            center.removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
            return
        }
        
        let date = Date()
        
        if item.dueDate > date {
            Task {
                await createNotification(for: item)
            }
        }
        else if item.dueDate < date && item.repeatFrequency != .Never {
            Task {
                await createRepeatingNotification(for: item)
            }
        }
    }
}

import SwiftUI
extension NotificationService {
    @ViewBuilder static func alertText() -> some View {
        if !NotificationService.notificationPermission {
            Text("Notifications are turned off")
        }
    }
}
