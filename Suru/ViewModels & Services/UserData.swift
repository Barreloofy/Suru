//
//  UserData.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:39 AM.
//

import Foundation
import UserNotifications

@MainActor
@Observable
final class UserData {
    var SuruItems = [SuruItem]()
    
    init() {
        loadUserData()
    }
    
    private func loadUserData() {
        try! SuruItems = StorageService.retrieveData()
    }
    
    func sortSuruItems() {
        SuruItems = SuruItems.sorted(by: <)
    }
    
    func remove(_ indexSet: IndexSet) {
        let itemsToRemove = indexSet.compactMap { SuruItems.indices.contains($0) ? SuruItems[$0].id.uuidString : nil }
        SuruItems.remove(atOffsets: indexSet)
        StorageService.store(userData: SuruItems)
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: itemsToRemove)
    }
}
