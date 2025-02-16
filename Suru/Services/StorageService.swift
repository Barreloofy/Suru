//
//  StorageService.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 4:41 PM.
//

import Foundation

struct StorageService {
    static var fileURL: URL {
        let documentsDirectory = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return documentsDirectory.appendingPathComponent("SuruUserData", conformingTo: .json)
    }
    
    static func store(_ suruItems: [SuruItem]) {
        let compactSuruItems = suruItems.compactMap { element in
            element.content.isEmpty ? nil : element
        }
        guard let data = try? JSONEncoder().encode(compactSuruItems) else { return }
        try! data.write(to: fileURL)
    }
    
    static func retrieve() throws -> [SuruItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return [] }
        let data = try Data(contentsOf: fileURL)
        let decodedSuruItems = try JSONDecoder().decode([SuruItem].self, from: data)
        return decodedSuruItems
    }
}
