//
//  CustomForm.swift
//  Suru
//
//  Created by Barreloofy on 3/5/25 at 6:31 PM.
//

import SwiftUI

struct CustomForm<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder _ content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                content
            }
            .padding(10)
            .background(DesignSystem.Colors.primary.opacity(0.75))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .padding()
            Spacer()
        }
        .background(DesignSystem.Colors.background.ignoresSafeArea())
    }
}
