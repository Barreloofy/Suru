//
//  SuruItemView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:23 AM.
//

import SwiftUI
import Combine

struct SuruItemView: View {
    @State private var viewModel = ItemViewModel()
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
        .sheet(isPresented: $viewModel.showDetails) {
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
            viewModel.completionHandler($item)
        }
        
        TextField("Suru...", text: $item.content)
            .tint(DesignSystem.Colors.tint)
            .focused($textFieldIsFocused)
            .disabled(item.completed ? true : false)
            .onChange(of: item.content) {
                viewModel.updateItem($item)
            }
        
        if textFieldIsFocused {
            Button {
                viewModel.showDetails.toggle()
                textFieldIsFocused = false
            } label: {
                Image(systemName: "info.circle")
            }
            .buttonStyle(.borderless)
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
        .foregroundStyle(
            item.dueDate > Date() ?
            DesignSystem.Colors.primaryText
            :
            DesignSystem.Colors.secondary
        )
    }
}

#Preview {
    SuruItemView(item: .constant(SuruItem()))
        .environment(UserData())
}
