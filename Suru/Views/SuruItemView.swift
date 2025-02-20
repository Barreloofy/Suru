//
//  SuruItemView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:23 AM.
//

import SwiftUI

struct SuruItemView: View {
    @FocusState private var textFieldIsFocused: Bool
    @State private var showSheet = false
    @Binding var item: SuruItem
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                RowContent
            }
            OverDue(item)
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
            NotificationService.shared.completionCheck(for: item)
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
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
    }
    
    
    @ViewBuilder private func OverDue(_ item: SuruItem) -> some View {
        if item.alert {
            Text(item.dueDate.formatted(date: .numeric, time: .shortened))
                .foregroundStyle(item.dueDate < Date() ? .autumnRed : .black)
        }
    }
}

#Preview {
    SuruItemView(item: .constant(SuruItem()))
        .environment(UserData())
}
