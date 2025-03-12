//
//  ListRowStyle.swift
//  Suru
//
//  Created by Barreloofy on 2/16/25 at 9:08 PM.
//

import SwiftUI

struct ListBackgroundStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .scrollContentBackground(.hidden)
            .background(DesignSystem.Colors.background)
    }
}


extension View {
    func listBackgroundStyle() -> some View {
        return self.modifier(ListBackgroundStyle())
    }
}


struct RowStyle: ViewModifier {
    func body(content: Content) -> some View {
        content
            .listRowBackground(DesignSystem.Colors.primary.opacity(0.75))
            .listRowSeparator(.hidden)
    }
}


extension View {
    func rowStyle() -> some View {
        return self.modifier(RowStyle())
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


func titleContent(_ title: String) -> some View {
    Text(title)
        .font(.title)
}
