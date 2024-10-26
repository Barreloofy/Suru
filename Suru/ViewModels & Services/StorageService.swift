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
    
    static func store(userData: [SuruItem]) {
        guard let data = try? JSONEncoder().encode(userData) else { return }
        try? data.write(to: fileURL)
    }
    
    static func retrieveData() throws -> [SuruItem] {
        guard FileManager.default.fileExists(atPath: fileURL.path()) else { return [] }
        let data = try Data(contentsOf: fileURL)
        let retrieveData = try JSONDecoder().decode([SuruItem].self, from: data)
        return retrieveData
    }
}
