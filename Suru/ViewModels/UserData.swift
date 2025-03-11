//
//  UserData.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:39 AM.
//

import Foundation
import UserNotifications
import Combine
import OSLog

@MainActor
@Observable
final class UserData {
    var SuruItems: [SuruItem]
    private var timer: AnyCancellable?
    
    init() {
        SuruItems = StorageService.retrieve()
    }
    
    private func debounce() {
        timer?.cancel()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else {
                    Logger().error("Self in closure #1 of debounce() function resolved to nil")
                    return
                }
                timer?.cancel()
                timer = nil
                sortSuruItems()
                StorageService.store(SuruItems)
            }
    }
    
    private func sortSuruItems() {
        var sortedSuruItems = SuruItems.sorted(by: <)
        
        sortedSuruItems.sort {
            !$0.completed && $1.completed
        }
        
        sortedSuruItems.sort {
            !$0.content.isEmpty && $1.content.isEmpty
        }
        
        SuruItems = sortedSuruItems
    }
    
    func update() {
        debounce()
    }
    
    func add() -> UUID {
        let newSuru = SuruItem()
        SuruItems.append(newSuru)
        return newSuru.id
    }
    
    func remove(at indexSet: IndexSet) {
        var notificationsToRemove = indexSet.compactMap {
            SuruItems.indices.contains($0) ? SuruItems[$0].strID : nil
        }
        
        notificationsToRemove.forEach {
            let idWithSuffix = $0 + "_repeating"
            notificationsToRemove.append(idWithSuffix)
        }
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationsToRemove)
        SuruItems.remove(atOffsets: indexSet)
        
        StorageService.store(SuruItems)
    }
    
    func remove(item: SuruItem) {
        guard let index = SuruItems.firstIndex(where: { $0 == item }) else { return }
        SuruItems.remove(at: index)
        
        let notificationToRemove = [item.strID, item.strID + "_repeating"]
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: notificationToRemove
        )
        
        StorageService.store(SuruItems)
    }
}
