//
//  UserData.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:39 AM.
//

import Foundation
import UserNotifications
import Combine

@MainActor
@Observable
final class UserData {
    var SuruItems = [SuruItem]()
    private var timer: AnyCancellable?
    
    init() {
        loadUserData()
    }
    
    private func loadUserData() {
        try! SuruItems = StorageService.retrieve()
    }
    
    private func debounce() {
        timer?.cancel()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
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
            SuruItems.indices.contains($0) ? SuruItems[$0].id.uuidString : nil
        }
        notificationsToRemove.forEach {
            let idWithSuffix = $0 + "_repeating"
            notificationsToRemove.append(idWithSuffix)
        }
        SuruItems.remove(atOffsets: indexSet)
        StorageService.store(SuruItems)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: notificationsToRemove)
    }
}
