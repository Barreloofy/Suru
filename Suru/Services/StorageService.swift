//
//  StorageService.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 4:41 PM.
//

import Foundation

#warning("StorageService refactor needed")
struct StorageService {
    static var userDataFileURL: URL {
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent("SuruUserData", conformingTo: .json)
    }
    
    static var repeatNotificationFileURL: URL {
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent("SuruRepeatNotifications", conformingTo: .json)
    }
    
    static func store(_ suruItems: [SuruItem], _ url: URL) {
        let compactSuruItems = suruItems.compactMap { element in
            element.content.isEmpty ? nil : element
        }
        guard let data = try? JSONEncoder().encode(compactSuruItems) else { return }
        try! data.write(to: url)
    }
    
    static func retrieve(_ url: URL) throws -> [SuruItem] {
        guard FileManager.default.fileExists(atPath: url.path()) else { return [] }
        let data = try Data(contentsOf: url)
        let decodedSuruItems = try JSONDecoder().decode([SuruItem].self, from: data)
        return decodedSuruItems
    }
}
