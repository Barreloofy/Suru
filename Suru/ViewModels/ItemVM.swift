//
//  ItemVM.swift
//  Suru
//
//  Created by Barreloofy on 2/21/25 at 5:49 PM.
//

import Combine
import SwiftUI
@preconcurrency import UserNotifications
import OSLog

fileprivate let logger = Logger(subsystem: "com.Item.Suru", category: "Error")
fileprivate enum ItemError: Error, LocalizedError {
    case nilValue
    
    var errorDescription: String {
        switch self {
            case .nilValue:
                return "Conditional statement resolves to nil"
        }
    }
}

@MainActor
@Observable
final class ItemViewModel {
    var showDetails = false
    private var timer: AnyCancellable?
    
    func handleCompletion(for item: Binding<SuruItem>) {
        guard item.wrappedValue.repeatFrequency != .Never else {
            NotificationService.shared.handleCompletionForFrequencyNever(for: item.wrappedValue)
            return
        }
        
        Task {
            await handleCompletionForRepeating(item)
        }
    }
    
    private func handleCompletionForRepeating(_ item: Binding<SuruItem>) async {
        do {
            let center = UNUserNotificationCenter.current()
            let notification = await center.pendingNotificationRequests()
                .first(where: {
                    $0.identifier == item.wrappedValue.strID
                    ||
                    $0.identifier == item.wrappedValue.strID + "_repeating"
                })
            
            guard let repeatingNotification = notification else {
                await NotificationService.shared.createRepeatingNotification(for: item.wrappedValue)
                try await toggleCompleted(item.completed)
                return
            }
            
            guard let trigger = repeatingNotification.trigger as? UNCalendarNotificationTrigger else {
                throw ItemError.nilValue
            }
            guard let triggerDate = trigger.nextTriggerDate() else {
                throw ItemError.nilValue
            }
            
            let dueDate = item.wrappedValue.dueDate
            item.wrappedValue.dueDate = dueDate > triggerDate ? dueDate : triggerDate
            
            try await toggleCompleted(item.completed)
            
        } catch {
            logger.error("\(error.localizedDescription)")
        }
    }
    
    private func toggleCompleted(_ value: Binding<Bool>) async throws {
        try await Task.sleep(for: .seconds(0.5))
        value.wrappedValue = false
    }
    
    func updateItem(_ item: Binding<SuruItem>) {
        guard !showDetails else { return }
        
        item.wrappedValue.content.lengthEnforcer()
        
        guard item.wrappedValue.alert else { return }
        debounceNotificationUpdate(item.wrappedValue)
    }
    
    private func debounceNotificationUpdate(_ item: SuruItem) {
        timer?.cancel()
        timer = Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {
                    logger.error("\(ItemError.nilValue.localizedDescription)")
                    return
                }
                timer?.cancel()
                timer = nil
                switch item.repeatFrequency {
                    case .Never:
                        Task {
                            await NotificationService.shared.createNotification(for: item)
                        }
                    default:
                        Task {
                            await NotificationService.shared.createRepeatingNotification(for: item)
                        }
                }
            }
    }
}
