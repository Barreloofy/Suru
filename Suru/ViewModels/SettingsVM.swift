//
//  SettingsVM.swift
//  Suru
//
//  Created by Barreloofy on 2/15/25 at 3:53 PM.
//

import Foundation
import OSLog
import UserNotifications

fileprivate let logger = Logger(subsystem: "com.Settings.suru", category: "Error")

@MainActor
@Observable
final class SettingsViewModel {
    var showImporter = false
    var showExporter = false
    var file: SuruItemsFile? = nil
    var importError = false
    var exportError = false
    
    func exportFile(_ suruItems: [SuruItem]) {
        file = SuruItemsFile(suruItems)
        showExporter.toggle()
    }
    
    func exportHandler(_ result: Result<URL, any Error>) {
        switch result {
            case .success(_):
                return
            case .failure(let failure):
                logger.error("\(failure)")
                exportError.toggle()
        }
    }
    
    func importFile(_ suruItems: inout [SuruItem], _ result: Result<URL, any Error>) {
        switch result {
            case .success(let success):
                do {
                    let data = try Data(contentsOf: success)
                    let decodedSuruItems = try JSONDecoder().decode([SuruItem].self, from: data)
                    suruItems = decodedSuruItems
                    StorageService.store(suruItems)
                    UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
                } catch {
                    logger.error("\(error)")
                    importError.toggle()
                }
            case .failure(let failure):
                logger.error("\(failure)")
                importError.toggle()
        }
    }
}
