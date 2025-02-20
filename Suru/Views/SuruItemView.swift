//
//  SuruItemView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:23 AM.
//

import SwiftUI

struct SuruItemView: View {
    @State private var showSheet = false
    @Binding var item: SuruItem
    @FocusState private var textFieldIsFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                RowContent
            }
            AlertStatusDate()
        }
        .foregroundStyle(item.completed ? .gray : .black)
        .sheet(isPresented: $showSheet) {
            DetailView(item: $item)
        }
    }
    
    
    @ViewBuilder private var RowContent: some View {
        Button {
            item.completed.toggle()
        } label: {
            Image(systemName: item.completed ? "circle.circle.fill" : "circle")
        }
        .buttonStyle(.borderless)
        .onChange(of: item.completed) {
            if item.repeatFrequency == .Never {
                NotificationService.shared.completionCheck(for: item)
            }
        }
        
        TextField("Suru...", text: $item.content)
            .tint(.autumnGreen)
            .focused($textFieldIsFocused)
            .disabled(item.completed ? true : false)
            .onChange(of: item.content) {
                guard !showSheet else { return }
                item.content.lengthEnforcer()
            }
        
        if textFieldIsFocused {
            Button {
                showSheet.toggle()
                textFieldIsFocused = false
            } label: {
                Image(systemName: "info.circle")
            }
        }
    }
    
    
    @ViewBuilder private func AlertStatusDate() -> some View {
        HStack {
            if item.alert {
                let formattedDate = item.dueDate.formatted(date: .numeric, time: .shortened)
                switch item.repeatFrequency {
                    case .Never:
                        Text(formattedDate)
                    default:
                        Text(formattedDate)
                        Image(systemName: "repeat")
                }
            }
        }
        .foregroundStyle(item.dueDate < Date() ? .autumnRed : .black)
    }
}

#Preview {
    SuruItemView(item: .constant(SuruItem()))
        .environment(UserData())
}
