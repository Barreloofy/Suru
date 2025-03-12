//
//  StorageService.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 4:41 PM.
//

import OSLog

fileprivate let logger = Logger(subsystem: "com.StorageService.Suru", category: "Error")

struct StorageService {
    static func userDataFileURL() throws -> URL {
        do {
            let documentsDirectory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            return documentsDirectory.appendingPathComponent("SuruUserData", conformingTo: .json)
        } catch {
            logger.error("\(error)")
            throw error
        }
    }
    
    static func store(_ suruItems: [SuruItem]) {
        do {
            let compactSuruItems = suruItems.compactMap { element in
                element.content.isEmpty ? nil : element
            }
            let data = try JSONEncoder().encode(compactSuruItems)
            try data.write(to: userDataFileURL())
        } catch {
            logger.error("\(error)")
        }
    }
    
    static func retrieve() -> [SuruItem] {
        do {
            guard FileManager.default.fileExists(atPath: try userDataFileURL().path()) else { return [] }
            let data = try Data(contentsOf: userDataFileURL())
            let decodedSuruItems = try JSONDecoder().decode([SuruItem].self, from: data)
            return decodedSuruItems
        } catch {
            logger.error("\(error)")
            fatalError()
        }
    }
}
