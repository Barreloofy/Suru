//
//  DetailView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:49 AM.
//

import SwiftUI

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var text = ""
    @Binding var item: SuruItem
    @FocusState private var isFocused: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                FormContent
            }
            .scrollContentBackground(.hidden)
            .background(.pastelGray)
            .foregroundStyle(.black)
            .tint(.autumnGreen)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Set") {
                        item.content = text
                        Task {
                            if item.repeatFrequency != .Never {
                                await NotificationService.createRepeatingNotification(for: item)
                            }
                            else {
                                await NotificationService.createNotification(for: item)
                            }
                            dismiss()
                        }
                    }
                    .font(.title3)
                }
                ToolbarItem(placement: .principal) {
                    Text("Details")
                        .font(.title)
                }
            }
        }
        .onAppear {
            text = item.content
        }
    }
    
    @ViewBuilder private var FormContent: some View {
        TextField("Suru...", text: $text)
            .listRowStyle()
            .onChange(of: text) {
                text.lengthEnforcer()
            }
        
        Group {
            Toggle("Alert", isOn: $item.alert)
            
            DatePicker("Dueby:", selection: $item.dueDate)
                .tint(.black)
            
            Picker("Repeat", selection: $item.repeatFrequency) {
                ForEach(Frequency.allCases) { frequency in
                    Text(frequency.rawValue)
                }
            }
            .tint(.black)
        }
        .listRowStyle()
        .disabled(NotificationService.notificationPermission ? false : true)
        .opacity(NotificationService.notificationPermission ? 1.0 : 0.25)
        
        NotificationService.alertText()
            .listRowStyle()
            .fontWeight(.regular)
    }
}

#Preview {
    DetailView(item: .constant(SuruItem()))
        .environment(UserData())
}
