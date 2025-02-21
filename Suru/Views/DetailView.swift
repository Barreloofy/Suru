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
    @State private var alert = UserDefaults.standard.bool(forKey: "defaultAlertValue")
    @Binding var item: SuruItem
    
    var body: some View {
        NavigationStack {
            Form {
                FormContent
            }
            .listBackgroundStyle()
            .foregroundStyle(.black)
            .tint(.autumnGreen)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Set") {
                        item.content = text
                        item.alert = alert
                        guard item.alert else {
                            dismiss()
                            let center = UNUserNotificationCenter.current()
                            center.removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
                            return
                        }
                        Task {
                            dismiss()
                            await NotificationService.shared.createNotification(for: item)
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
        TextField("Suru...", text: $text, axis: .vertical)
            .rowStyle()
            .onChange(of: text) {
                text.lengthEnforcer()
            }
        
        Group {
            Toggle("Alert", isOn: $alert)
            
            DatePicker("Dueby:", selection: $item.dueDate)
                .tint(.black)
            
            Picker("Repeat", selection: $item.repeatFrequency) {
                ForEach(Frequency.allCases) { frequency in
                    Text(frequency.rawValue)
                }
            }
            .tint(.black)
        }
        .rowStyle()
        .disabled(NotificationService.shared.notificationPermission ? false : true)
        .opacity(NotificationService.shared.notificationPermission ? 1.0 : 0.25)
        
        NotificationService.shared.alertText()
            .rowStyle()
            .fontWeight(.regular)
    }
}

#Preview {
    DetailView(item: .constant(SuruItem()))
        .environment(UserData())
}
