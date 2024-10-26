//
//  SuruItemVM.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 4:46 PM.
//

import Foundation
import Combine

@MainActor
final class SuruItemViewModel {
    private var saveTimer: AnyCancellable?
    
    func save(userData: [SuruItem]) {
        saveTimer?.cancel()
        saveTimer = Timer.publish(every: 0.5, on: .main, in: .common)
            .autoconnect()
            .sink { [ weak self] _ in
                StorageService.store(userData: userData)
                self?.saveTimer = nil
            }
    }
}
