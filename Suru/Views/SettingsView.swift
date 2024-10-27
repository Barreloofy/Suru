//
//  SettingsView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 9:18 PM.
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var defaultAlertValue: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                Toggle("Alert", isOn: $defaultAlertValue)
                    .listRowBackground(Color.autumnOrange.opacity(0.75))
                    .listRowSeparator(.hidden)
                    .tint(.autumnGreen)
                    .bold()
                    .disabled(NotificationService.notificationPermission ? false : true)
                    .opacity(NotificationService.notificationPermission ? 1.0 : 0.25)
                    .onChange(of: defaultAlertValue) {
                        UserDefaults.standard.set(defaultAlertValue, forKey: "defaultAlertValue")
                    }
                NotificationService.alertText()
            }
            .scrollContentBackground(.hidden)
            .background(.pastelGray)
            
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .tint(.autumnOrange)
                    .bold()
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.title)
                        .bold()
                }
            }
        }
    }
}

#Preview {
    SettingsView(defaultAlertValue: .constant(false))
}
