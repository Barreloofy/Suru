//
//  NotificationService.swift
//  Suru
//
//  Created by Barreloofy on 10/26/24 at 4:03 PM.
//

import Foundation
@preconcurrency import UserNotifications
import OSLog

fileprivate let logger = Logger(subsystem: "com.NotificationService.suru", category: "Error")

@MainActor
class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    var notificationPermission = false
    var tappedNotification: String?
    
    private init() {}
    
    func notificationAuthorization() {
        Task {
            notificationPermission = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        }
    }
    
    func cleanup() {
        Task {
            do {
                try await center.setBadgeCount(0)
                let deliveredNotifications = await center.deliveredNotifications()
                deliveredNotifications.forEach { notification in
                    var notificationID = notification.request.identifier
                    if notificationID.hasSuffix("_repeating") {
                        Task {
                            notificationID = String(notificationID.dropLast(10))
                            NotificationService.shared.tappedNotification = notificationID
                            await NotificationService.shared.createRepeatingNotification(notification, notificationID)
                        }
                    }
                }
            } catch {
                logger.error("\(error)")
            }
        }
    }
    
    func badgeUpdater() async {
        let pendingNotifications = await center.pendingNotificationRequests().sorted {
            guard let lhsTrigger = $0.trigger as? UNCalendarNotificationTrigger, let lhsTriggerDate = lhsTrigger.nextTriggerDate() else {
                logger.info("Type cast or conditional unwrapping failed")
                return false
            }
            guard let rhsTrigger = $1.trigger as? UNCalendarNotificationTrigger, let rhsTriggerDate = rhsTrigger.nextTriggerDate() else {
                logger.info("Type cast or conditional unwrapping failed")
                return false
            }
            return lhsTriggerDate < rhsTriggerDate
        }
        
        pendingNotifications.enumerated().forEach { index, request in
            let content = request.content
            guard let updatedContent = content.mutableCopy() as? UNMutableNotificationContent else {
                logger.info("Type cast failed")
                return
            }
            updatedContent.badge = NSNumber(value: index + 1)
            let updatedRequest = UNNotificationRequest(identifier: request.identifier, content: updatedContent, trigger: request.trigger)
            center.add(updatedRequest)
        }
    }
    
    func configureDateComponents(for date: Date, with repeatValue: Frequency) -> DateComponents {
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
    
    func configureBadge(_ dueDate: Date) async -> NSNumber {
        let pendingNotifications = await center.pendingNotificationRequests()
        var count = 1
        pendingNotifications.forEach { notification in
            guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else {
                logger.info("Type cast failed")
                return
            }
            guard let triggerDate = trigger.nextTriggerDate() else {
                logger.info("Type cast failed")
                return
            }
            if dueDate > triggerDate || dueDate == triggerDate { count += 1 }
        }
        return NSNumber(value: count)
    }
    
    func createNotification(for item: SuruItem) async {
        guard item.alert, item.dueDate > Date() else { return }
        let id = item.repeatFrequency != .Never ? item.id.uuidString + "_repeating" : item.id.uuidString
        let content = UNMutableNotificationContent()
        content.body = item.content
        content.sound = .default
        content.badge = await configureBadge(item.dueDate)
        content.userInfo = ["repeatFrequency": item.repeatFrequency.rawValue]
        let dateComponents = configureDateComponents(for: item.dueDate, with: .Never)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            logger.error("\(error)")
        }
    }
    
    func createRepeatingNotification(for item: SuruItem) async {
        guard item.alert, item.repeatFrequency != .Never else { return }
        do {
            let id = item.id.uuidString
            let content = UNMutableNotificationContent()
            guard let badgeDate = Calendar.current.date(byAdding: try item.repeatFrequency.toComponent(), value: 1, to: item.dueDate) else { return }
            content.body = item.content
            content.sound = .default
            content.badge = await configureBadge(badgeDate)
            let dateComponents = configureDateComponents(for: item.dueDate, with: item.repeatFrequency)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            try await center.add(request)
        } catch {
            logger.error("\(error)")
        }
    }
    
    func createRepeatingNotification(_ notification: UNNotification, _ id: String) async {
        do {
            guard let content = notification.request.content.mutableCopy() as? UNMutableNotificationContent else { return }
            guard let frequencyString = content.userInfo["repeatFrequency"] as? String, let frequency = Frequency(rawValue: frequencyString) else { return }
            guard let badgeDate = Calendar.current.date(byAdding: try frequency.toComponent(), value: 1, to: notification.date) else { return }
            content.badge = await configureBadge(badgeDate)
            let dateComponents = configureDateComponents(for: notification.date, with: frequency)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            try await center.add(request)
        } catch {
            logger.error("\(error)")
        }
    }
    
    func completionCheck(for item: SuruItem) {
        guard item.repeatFrequency == .Never else { return }
        switch item.alert {
            case true:
                Task {
                    await createNotification(for: item)
                }
            case false:
                let id = item.id.uuidString
                center.removePendingNotificationRequests(withIdentifiers: [id])
        }
    }
}

import SwiftUI
extension NotificationService {
    @ViewBuilder func alertText() -> some View {
        if !notificationPermission {
            Text("Notifications are turned off")
        }
    }
}
