//
//  ListRowStyle.swift
//  Suru
//
//  Created by Barreloofy on 2/16/25 at 9:08 PM.
//

import SwiftUI

struct ListRowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(Color.autumnOrange.opacity(0.75))
            .listRowSeparator(.hidden)
            .bold()
    }
}


extension View {
    func listRowStyle() -> some View {
        return self.modifier(ListRowStyle())
    }
}
