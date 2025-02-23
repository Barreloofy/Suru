//
//  DetailVM.swift
//  Suru
//
//  Created by Barreloofy on 2/22/25 at 9:40 PM.
//

import Foundation
import SwiftUI

@MainActor
@Observable
final class DetailViewModel {
    var text = ""
    var alert = UserDefaults.standard.bool(forKey: "defaultAlertValue")
    
    func set(for item: Binding<SuruItem>) {
        item.wrappedValue.content = text
        item.wrappedValue.alert = alert
        guard item.wrappedValue.alert else {
            let center = UNUserNotificationCenter.current()
            center.removePendingNotificationRequests(withIdentifiers: [item.wrappedValue.id.uuidString])
            return
        }
        Task {
            await NotificationService.shared.createNotification(for: item.wrappedValue)
        }
    }
}
