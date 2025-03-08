//
//  SettingsError.swift
//  Suru
//
//  Created by Barreloofy on 2/22/25 at 11:46 PM.
//

import SwiftUI

/*  Doesn't dismiss itself */

struct SettingsError<A,M>: ViewModifier where A : View, M : View {
    let titleKey: LocalizedStringKey
    var isPresented: Binding<Bool>
    let actions: () -> A
    let message: () -> M
    
    init(_ titleKey: LocalizedStringKey, isPresented: Binding<Bool>, @ViewBuilder actions: @escaping () -> A, @ViewBuilder message: @escaping () -> M) {
        self.titleKey = titleKey
        self.isPresented = isPresented
        self.actions = actions
        self.message = message
    }
    
    func body(content: Content) -> some View {
        ZStack {
            content
            if isPresented.wrappedValue {
                GeometryReader { proxy in
                    
                    let xPosition = proxy.size.width / 2
                    let yPosition = proxy.size.height / 2
                    let width = proxy.size.width * 0.70
                    
                    VStack {
                        
                        Text(titleKey)
                        
                        message()
                        
                        Divider()
                            .frame(maxHeight: 1)
                            .background(Color(.gray))
                        
                        actions()
                    }
                    .padding(.vertical)
                    .bold()
                    .foregroundStyle(DesignSystem.Colors.background)
                    .background(DesignSystem.Colors.secondary)
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                    .position(x: xPosition, y: yPosition)
                    .frame(width: width)
                }
            }
        }
    }
}

extension View {
    func settingsError<A, M>(
        _ titleKey: LocalizedStringKey,
        isPresented: Binding<Bool>,
        actions: @escaping () -> A,
        message: @escaping () -> M = { EmptyView() }
    ) -> some View where A : View, M : View {
        return self.modifier(SettingsError(titleKey, isPresented: isPresented, actions: actions, message: message))
    }
}
