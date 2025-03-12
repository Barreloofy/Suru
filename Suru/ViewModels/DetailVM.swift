//
//  DetailVM.swift
//  Suru
//
//  Created by Barreloofy on 2/22/25 at 9:40 PM.
//

import SwiftUI
@preconcurrency import UserNotifications

@MainActor
@Observable
final class DetailViewModel {
    var item: SuruItem
    var alert = UserDefaults.standard.bool(forKey: "defaultAlertValue")
    
    init(item: SuruItem) {
        self.item = item
    }
    
    func set(for item: Binding<SuruItem>) {
        item.wrappedValue = self.item
        item.wrappedValue.alert = self.alert
        
        guard item.wrappedValue.alert else {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [item.wrappedValue.strID])
            return
        }
        
        Task {
            let center = UNUserNotificationCenter.current()
            
            let itemIsNotification = await center.pendingNotificationRequests()
                .contains(where: {
                    $0.identifier == item.wrappedValue.strID
                })
            
            if !itemIsNotification {
                await NotificationService.shared.createNotification(for: item.wrappedValue)
            }
        }
    }
    
    func initiateAlert(_ itemAlert: Bool) {
        guard itemAlert && NotificationService.shared.notificationPermission else { return }
        alert = true
    }
}
