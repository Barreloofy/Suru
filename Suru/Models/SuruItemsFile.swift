//
//  SuruItemsFile.swift
//  Suru
//
//  Created by Barreloofy on 2/15/25 at 3:13 PM.
//

import UniformTypeIdentifiers
import SwiftUI

struct SuruItemsFile: FileDocument {
    static let readableContentTypes: [UTType] = [.json]
    let suruItems: [SuruItem]
    
    init(_ suruItems: [SuruItem]) {
        self.suruItems = suruItems
    }
    
    init(configuration: ReadConfiguration) throws {
        guard let data = configuration.file.regularFileContents else { throw FileError.configurationError }
        suruItems = try JSONDecoder().decode([SuruItem].self, from: data)
    }
    
    func fileWrapper(configuration: WriteConfiguration) throws -> FileWrapper {
        let data = try JSONEncoder().encode(suruItems)
        return FileWrapper(regularFileWithContents: data)
    }
}

extension SuruItemsFile {
    enum FileError: Error, LocalizedError {
        case configurationError
        
        var localizedDescription: String {
            switch self {
                case .configurationError:
                    return "configuration.file.regularFileContents in init(configuration: ReadConfiguration) throws produced an error"
            }
        }
    }
}
