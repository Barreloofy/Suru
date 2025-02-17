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
    }
}


extension View {
    func listRowStyle() -> some View {
        return self.modifier(ListRowStyle())
    }
}


struct ToolbarStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackgroundVisibility(.visible, for: .bottomBar)
            .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
    }
}


extension View {
    func toolbarStyle() -> some View {
        return self.modifier(ToolbarStyle())
    }
}
