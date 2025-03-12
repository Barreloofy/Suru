//
//  NotificationService.swift
//  Suru
//
//  Created by Barreloofy on 10/26/24 at 4:03 PM.
//

@preconcurrency import UserNotifications
import OSLog

fileprivate let logger = Logger(subsystem: "com.NotificationService.suru", category: "Error")
enum NotificationError: Error, LocalizedError {
    case castFail
    case unwrappingFail
    
    var errorDescription: String? {
        switch self {
            case .castFail:
                return "Type cast failed"
            case .unwrappingFail:
                return "conditional unwrapping failed"
        }
    }
}

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
    
    func refreshNotificationState() async {
        do {
            try await center.setBadgeCount(0)
            
            let deliveredNotifications = await center.deliveredNotifications()
            
            for notification in deliveredNotifications {
                let notificationID = notification.request.identifier
                
                guard notificationID.hasSuffix("_repeating") else {
                    center.removeDeliveredNotifications(withIdentifiers: [notificationID])
                    continue
                }
                
                let trimmedNotificationID = String(notificationID.dropLast(10))
                center.removeDeliveredNotifications(withIdentifiers: [trimmedNotificationID])
                Task {
                    await createRepeatingNotification(notification: notification, id: trimmedNotificationID)
                }
            }
        }
        catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    func updateBadge() async {
        let pendingNotifications = await center.pendingNotificationRequests()
            .sorted {
                do {
                    let lhsTriggerDate = try castToCalendarTrigger(for: $0.trigger)
                    
                    let rhsTriggerDate = try castToCalendarTrigger(for: $1.trigger)
                    
                    return lhsTriggerDate < rhsTriggerDate
                } catch {
                    logger.error("\(error.localizedDescription)")
                    return false
                }
            }
        
        for (index, request) in pendingNotifications.enumerated() {
            let updatedContent = request.content.mutableCopy() as! UNMutableNotificationContent
            updatedContent.badge = NSNumber(value: index + 1)
            
            let updatedRequest = UNNotificationRequest(
                identifier: request.identifier,
                content: updatedContent,
                trigger: request.trigger
            )
            do {
                try await center.add(updatedRequest)
            } catch {
                logger.error("\(error.localizedDescription)")
            }
        }
    }
    
    private func configureDateComponents(for date: Date, with repeatValue: Frequency) -> DateComponents {
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
    
    private func configureBadge(_ dueDate: Date) async -> NSNumber {
        let pendingNotifications = await center.pendingNotificationRequests()
        var count = 1
        
        pendingNotifications.forEach {
            do {
                let triggerDate = try castToCalendarTrigger(for: $0.trigger)
                if dueDate > triggerDate || dueDate == triggerDate { count += 1}
            } catch {
                logger.error("\(error.localizedDescription)")
                return
            }
        }
        
        return NSNumber(value: count)
    }
    
    func createNotification(for item: SuruItem) async {
        guard item.alert, item.dueDate > Date() else { return }
        
        let id = item.repeatFrequency != .Never ? item.strID + "_repeating" : item.strID
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
            logger.error("\(error.localizedDescription)")
        }
    }
    
    func createRepeatingNotification(for item: SuruItem) async {
        guard item.alert, item.repeatFrequency != .Never else { return }
        do {
            let badgeDate = try createBadgeDate(with: item.repeatFrequency, from: item.dueDate)
            let content = UNMutableNotificationContent()
            
            content.body = item.content
            content.sound = .default
            content.badge = await configureBadge(badgeDate)
            
            let dateComponents = configureDateComponents(for: item.dueDate, with: item.repeatFrequency)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
           
            let request = UNNotificationRequest(identifier: item.strID, content: content, trigger: trigger)
            try await center.add(request)
        } catch {
            logger.error("\(error)")
        }
    }
    
    func createRepeatingNotification(notification: UNNotification, id: String) async {
        do {
            let content = notification.request.content.mutableCopy() as! UNMutableNotificationContent
            
            guard let frequencyStr = content.userInfo["repeatFrequency"] as? String else { throw NotificationError.castFail }
            guard let frequency = Frequency(rawValue: frequencyStr) else { throw NotificationError.unwrappingFail }
            
            let badgeDate = try createBadgeDate(with: frequency, from: notification.date)
            content.badge = await configureBadge(badgeDate)
            
            let dateComponents = configureDateComponents(for: notification.date, with: frequency)
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            
            let request = UNNotificationRequest(identifier: id, content: content, trigger: trigger)
            try await center.add(request)
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    func handleCompletionForFrequencyNever(for item: SuruItem) {
        guard item.repeatFrequency == .Never else { return }
        
        switch item.completed {
            case true:
                center.removePendingNotificationRequests(withIdentifiers: [item.strID])
            case false:
                Task {
                    await createNotification(for: item)
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

private func castToCalendarTrigger(for trigger: UNNotificationTrigger?) throws -> Date {
    guard let CalendarTrigger = trigger as? UNCalendarNotificationTrigger else { throw NotificationError.castFail }
    guard let triggerDate = CalendarTrigger.nextTriggerDate() else { throw NotificationError.unwrappingFail }
    return triggerDate
}

private func createBadgeDate(with frequency: Frequency, from date: Date) throws -> Date {
    guard let badgeDate = Calendar.current.date(
        byAdding: try frequency.toComponent(),
        value: 1,
        to: date
    )
    else { throw NotificationError.unwrappingFail }
    
    return badgeDate
}
