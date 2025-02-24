//
//  ItemVM.swift
//  Suru
//
//  Created by Barreloofy on 2/21/25 at 5:49 PM.
//

import Foundation
import Combine
@preconcurrency import SwiftUI
import OSLog

fileprivate let logger = Logger(subsystem: "com.Item.Suru", category: "Error")
fileprivate enum ItemError: Error, LocalizedError {
    case nilValue
    
    var localizedDescription: String {
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
    
    func completionHandler(_ item: Binding<SuruItem>) {
        if item.wrappedValue.repeatFrequency == .Never {
            NotificationService.shared.completionCheck(for: item.wrappedValue)
        }
        else {
            Task {
                do {
                    guard let repeatingNotification = await UNUserNotificationCenter.current()
                        .pendingNotificationRequests()
                        .first(where: {  $0.identifier == item.wrappedValue.id.uuidString })
                    else {
                        throw ItemError.nilValue
                    }
                    guard let trigger = repeatingNotification.trigger as? UNCalendarNotificationTrigger else {
                        throw ItemError.nilValue
                    }
                    guard let triggerDate = trigger.nextTriggerDate() else {
                        throw ItemError.nilValue
                    }
                    item.wrappedValue.dueDate = triggerDate
                    try await Task.sleep(for: .seconds(0.25))
                    item.wrappedValue.completed = false
                } catch {
                    logger.error("\(error)")
                }
            }
        }
    }
    
    func updateItem(_ item: Binding<SuruItem>) {
        guard !showDetails else { return }
        item.wrappedValue.content.lengthEnforcer()
        guard item.wrappedValue.alert else { return }
        debounceNotificationUpdate(item.wrappedValue)
    }
    
    private func debounceNotificationUpdate(_ item: SuruItem) {
        timer?.cancel()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
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
