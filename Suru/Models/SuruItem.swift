//
//  SuruItem.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:29 AM.
//

import Foundation

struct SuruItem: Identifiable, Codable {
    let id: UUID
    var dueDate: Date
    var content: String
    var completed: Bool
    var alert: Bool
    
    init(alert: Bool = false) {
        id = UUID()
        dueDate = Calendar.current.date(byAdding: .day, value: 1, to: Calendar.current.startOfDay(for: Date()))!
        content = ""
        completed = false
        self.alert = alert
    }
}
