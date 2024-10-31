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
                    .onChange(of: item.content) {
                        item.lengthEnforcer()
                    }
                
                Group {
                    Toggle("Alert", isOn: $item.alert)
                        .tint(.autumnGreen)
                    
                    DatePicker("Dueby:", selection: $item.dueDate)
                    
                    Picker("Repeat", selection: $item.repeatFrequency) {
                        ForEach(Frequency.allCases) { frequency in
                            Text(frequency.rawValue)
                        }
                    }
                    .tint(.black)
                }
                .listRowBackground(Color.autumnOrange.opacity(0.75))
                .listRowSeparator(.hidden)
                .disabled(NotificationService.notificationPermission ? false : true)
                .opacity(NotificationService.notificationPermission ? 1.0 : 0.25)
                
                NotificationService.alertText()
            }
            .scrollContentBackground(.hidden)
            .background(.pastelGray)
            .tint(.pastelGray)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Set") {
                        StorageService.store(userData: userData.SuruItems)
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
