//
//  SuruItem.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:29 AM.
//

import Foundation

struct SuruItem: Identifiable, Comparable, Codable {
    static func < (lhs: SuruItem, rhs: SuruItem) -> Bool {
        guard !lhs.content.isEmpty else { return false }
        return lhs.dueDate < rhs.dueDate ? true : false
    }
    
    let id: UUID
    var dueDate: Date
    var content: String
    var completed: Bool
    var alert: Bool
    var repeatFrequency: Frequency
    
    init() {
        self.id = UUID()
        self.dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        self.content = ""
        self.completed = false
        self.alert = false
        self.repeatFrequency = Frequency.Never
    }
    
    var strID: String {
        return id.uuidString
    }
}

enum Frequency: String, CaseIterable, Identifiable, Codable {
    case Never, Hourly, Daily, Weekly, Monthly, Yearly
    var id: Self { self }
    
    private enum FrequencyError: Error, LocalizedError {
        case noAssociatedComponent
        
        var localizedDescription: String {
            switch self {
                case .noAssociatedComponent:
                    return "Value 'Never' dosen't correspond to any Component"
            }
        }
    }
    
    func toComponent() throws -> Calendar.Component {
        switch self {
            case .Never:
                throw FrequencyError.noAssociatedComponent
            case .Hourly:
                return .hour
            case .Daily:
                return .day
            case .Weekly:
                return .weekOfYear
            case .Monthly:
                return .month
            case .Yearly:
                return .year
        }
    }
}


extension String {
    mutating func lengthEnforcer() {
        guard self.count > 256 else { return }
        self = String(self.prefix(256))
    }
}
