//
//  SuruItem.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:29 AM.
//

import Foundation

struct SuruItem: Identifiable, Codable, Comparable {
    static func < (lhs: SuruItem, rhs: SuruItem) -> Bool {
        return lhs.dueDate < rhs.dueDate ? true : false
    }
    
    init(alert: Bool = false) {
        id = UUID()
        dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        content = ""
        completed = false
        self.alert = alert
        repeatFrequency = Frequency.Never
    }
    
    let id: UUID
    var dueDate: Date
    var content: String
    var completed: Bool
    var alert: Bool
    var repeatFrequency: Frequency
    
    mutating func lengthEnforcer() {
        print("Start")
        if content.count > 256 {
            content = String(content.prefix(256))
        }
    }
}

enum Frequency: String, CaseIterable, Identifiable, Codable {
    var id: Self { self }
    case Never, Hourly, Daily, Weekly, Monthly, Yearly
}
