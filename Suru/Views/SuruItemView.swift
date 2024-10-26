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
                    
                }
                TextField("Suru...", text: $item.content)
                    .foregroundStyle(item.completed ? .gray : .black)
                    .focused($textFieldIsFocused)
                    .onChange(of: item.content) {
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
                Text(item.dueDate.formatted(date: .numeric, time: .shortened))
                Spacer()
            }
        }
        .tint(.black)
    }
}

#Preview {
    SuruItemView(item: .constant(SuruItem()))
        .environment(UserData())
}
