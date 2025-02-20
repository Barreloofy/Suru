//
//  NotificationService.swift
//  Suru
//
//  Created by Barreloofy on 10/26/24 at 4:03 PM.
//

import Foundation
@preconcurrency import UserNotifications
import OSLog

private let logger = Logger(subsystem: "com.NotificationService.suru", category: "Error")

@MainActor
class NotificationService {
    static let shared = NotificationService()
    private let center = UNUserNotificationCenter.current()
    var notificationPermission = false
    var tappedNotification: String?
    var firstTimeRepeatingNotifications = [SuruItem]() {
        didSet {
            StorageService.store(firstTimeRepeatingNotifications, StorageService.repeatNotificationFileURL)
        }
    }
#warning("Not persistent")
    
    private init() {
        firstTimeRepeatingNotifications = try! StorageService.retrieve(StorageService.repeatNotificationFileURL)
    }
    
    func notificationAuthorization() {
        Task {
            notificationPermission = (try? await center.requestAuthorization(options: [.alert, .sound, .badge])) ?? false
        }
    }
    
    func cleanup() {
        center.setBadgeCount(0)
        center.removeAllDeliveredNotifications()
    }
    
    func badgeUpdater() {
        Task.detached(priority: .high) { [weak self] in
            guard let self = self else { return }
            let pendingNotifications = await center.pendingNotificationRequests().sorted {
                guard let lhsTrigger = $0.trigger as? UNCalendarNotificationTrigger, let lhsTriggerDate = lhsTrigger.nextTriggerDate() else { return false }
                guard let rhsTrigger = $1.trigger as? UNCalendarNotificationTrigger, let rhsTriggerDate = rhsTrigger.nextTriggerDate() else { return false }
                return lhsTriggerDate < rhsTriggerDate
            }
            
            await MainActor.run {
                pendingNotifications.enumerated().forEach { index, request in
                    let updatedContent = request.content.mutableCopy() as! UNMutableNotificationContent
                    updatedContent.badge = NSNumber(value: index + 1)
                    let updatedRequest = UNNotificationRequest(identifier: request.identifier, content: updatedContent, trigger: request.trigger)
                    center.add(updatedRequest)
                }
            }
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
            guard let trigger = notification.trigger as? UNCalendarNotificationTrigger else { return }
            guard let triggerDate = trigger.nextTriggerDate() else { return }
            if dueDate > triggerDate { count += 1 }
        }
        return NSNumber(value: count)
    }
    
    func createNotification(for item: SuruItem) async {
        guard item.alert, item.dueDate > Date() else { return }
        let content = UNMutableNotificationContent()
        content.body = item.content
        content.sound = UNNotificationSound.default
        content.badge = await configureBadge(item.dueDate)
        //let dateComponents = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: item.dueDate)
        let dateComponents = configureDateComponents(for: item.dueDate, with: .Never)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            logger.error("\(error)")
        }
    }
    
#warning("Ignores all but the repeatFrequency date component")
    func createRepeatingNotification(for item: SuruItem) async {
        guard item.alert else { return }
        let content = UNMutableNotificationContent()
        content.body = item.content
        content.sound = UNNotificationSound.default
        content.badge = await configureBadge(item.dueDate)
        let dateComponents = configureDateComponents(for: item.dueDate, with: item.repeatFrequency)
        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
        let request = UNNotificationRequest(identifier: item.id.uuidString, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            logger.error("\(error)")
        }
    }
    
#warning("in progress")
    func completionCheck(for item: SuruItem) {
        guard !item.completed && item.alert else {
            center.removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
            return
        }
        
        let date = Date()
        
        switch item.repeatFrequency {
            case .Never:
                guard item.dueDate > date else { return }
                Task {
                    await createNotification(for: item)
                }
            default:
                let newDate: Date?
                let calendar = Calendar.current
                let oldDate = item.dueDate
                switch item.repeatFrequency {
                    case .Never:
                        fatalError("Error")
                    case .Hourly:
                        newDate = calendar.date(byAdding: .hour, value: 1, to: oldDate)
                    case .Daily:
                        newDate = calendar.date(byAdding: .day, value: 1, to: oldDate)
                    case .Weekly:
                        newDate = calendar.date(byAdding: .day, value: 7, to: oldDate)
                    case .Monthly:
                        newDate = calendar.date(byAdding: .month, value: 1, to: oldDate)
                    case .Yearly:
                        newDate = calendar.date(byAdding: .year, value: 1, to: oldDate)
                }
                guard let newDate = newDate else { fatalError("Error, again") }
                var newItem = item
                newItem.dueDate = newDate
                Task {
                    await createRepeatingNotification(for: newItem)
                }
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
