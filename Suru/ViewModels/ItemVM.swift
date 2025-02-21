//
//  ItemVM.swift
//  Suru
//
//  Created by Barreloofy on 2/21/25 at 5:49 PM.
//

import Foundation
import Combine
import SwiftUI

@MainActor
@Observable
final class ItemViewModel {
    var showSheet = false
    private var timer: AnyCancellable?
    
    func completionHandler(_ item: SuruItem) {
        if item.repeatFrequency == .Never {
            NotificationService.shared.completionCheck(for: item)
        }
    }
    
    func updateItem(_ item: Binding<SuruItem>) {
        guard !showSheet else { return }
        item.wrappedValue.content.lengthEnforcer()
        guard item.wrappedValue.alert else { return }
        debounceNotificationUpdate(item.wrappedValue)
    }
    
    private func debounceNotificationUpdate(_ item: SuruItem) {
        timer?.cancel()
        timer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
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
