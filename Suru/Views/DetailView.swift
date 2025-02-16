//
//  DetailView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 1:49 AM.
//

import SwiftUI
import UserNotifications

struct DetailView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var item: SuruItem
    @State private var text = ""
    
    var body: some View {
        NavigationStack {
            Form {
                TextField("Suru...", text: $text)
                    .listRowBackground(Color.autumnOrange.opacity(0.75))
                    .listRowSeparator(.hidden)
                    .onChange(of: text) {
                        text.lengthEnforcer()
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
                    .fontWeight(.light)
                    .listRowStyle()
            }
            .scrollContentBackground(.hidden)
            .background(.pastelGray)
            .tint(.pastelGray)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Set") {
                        item.content = text
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
        .onAppear {
            text = item.content
        }
    }
}

#Preview {
    DetailView(item: .constant(SuruItem()))
        .environment(UserData())
}
