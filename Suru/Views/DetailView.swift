//
//  DetailView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:49 AM.
//

import SwiftUI
import UserNotifications

struct DetailView: View {
    @Environment(UserData.self) private var userData
    @Environment(\.dismiss) private var dismiss
    @Binding var item: SuruItem
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Suru...", text: $item.content)
                    .listRowBackground(Color.autumnOrange.opacity(0.75))
                    .listRowSeparator(.hidden)
                
                Toggle("Alert", isOn: $item.alert)
                    .listRowBackground(Color.autumnOrange.opacity(0.75))
                    .listRowSeparator(.hidden)
                    .tint(.autumnGreen)
                    .disabled(NotificationService.notificationPermission ? false : true)
                    .opacity(NotificationService.notificationPermission ? 1.0 : 0.25)
                NotificationService.alertText()
                
                DatePicker("Dueby:", selection: $item.dueDate)
                    .listRowBackground(Color.autumnOrange.opacity(0.75))
                    .onChange(of: item.dueDate) {
                        StorageService.store(userData: userData.SuruItems)
                    }
            }
            .scrollContentBackground(.hidden)
            .background(.pastelGray)
            .tint(.pastelGray)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Set") {
                        NotificationService.createNotification(for: item)
                        dismiss()
                    }
                    .tint(.autumnOrange)
                    .bold()
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Details")
                        .font(.title)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    DetailView(item: .constant(SuruItem()))
        .environment(UserData())
}
