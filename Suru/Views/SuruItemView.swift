//
//  SuruItemView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:23 AM.
//

import SwiftUI

struct SuruItemView: View {
    @State private var viewModel = SuruItemViewModel()
    @Environment(UserData.self) private var userData
    @FocusState private var textFieldIsFocused: Bool
    @State private var showSheet = false
    @Binding var item: SuruItem
    private let date = Date()
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    item.completed.toggle()
                } label: {
                    Image(systemName: item.completed ? "circle.circle.fill" : "circle")
                        .foregroundStyle(item.completed ? .gray : .black)
                }
                .onChange(of: item.completed) {
                    NotificationService.completionCheck(for: item)
                    viewModel.save(userData: userData.SuruItems)
                }
                TextField("Suru...", text: $item.content)
                    .foregroundStyle(item.completed ? .gray : .black)
                    .focused($textFieldIsFocused)
                    .onChange(of: item.content) {
                        if !showSheet {
                            item.lengthEnforcer()
                        }
                        viewModel.save(userData: userData.SuruItems)
                    }
                
                if textFieldIsFocused {
                    Button {
                        showSheet.toggle()
                    } label: {
                        Image(systemName: "info.circle")
                    }
                    .buttonStyle(BorderlessButtonStyle())
                    .tint(.black)
                }
            }
            .bold()
            .sheet(isPresented: $showSheet) {
                DetailView(item: $item)
            }
            
            HStack {
                if item.alert {
                    Text(item.dueDate.formatted(date: .numeric, time: .shortened))
                        .foregroundStyle(item.dueDate < date ? .autumnRed : .black)
                    Spacer()
                }
            }
        }
        .tint(.black)
    }
}

#Preview {
    SuruItemView(item: .constant(SuruItem()))
        .environment(UserData())
}
