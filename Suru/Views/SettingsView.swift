//
//  SettingsView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 9:18 PM.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel()
    @Environment(UserData.self) private var userData
    @Environment(\.dismiss) private var dismiss
    @Binding var defaultAlertValue: Bool
    
    var body: some View {
        NavigationStack {
            Form {
                AlertSetting
                UserDataSettings
            }
            .scrollContentBackground(.hidden)
            .background(.pastelGray)
            .alert("Import failed", isPresented: $viewModel.importError) {}
            .alert("Export failed", isPresented: $viewModel.exportError) {}
            
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
    
    @ViewBuilder private var AlertSetting: some View {
        Group {
            Toggle("Alert", isOn: $defaultAlertValue)
                .tint(.autumnGreen)
                .disabled(NotificationService.notificationPermission ? false : true)
                .opacity(NotificationService.notificationPermission ? 1.0 : 0.25)
                .onChange(of: defaultAlertValue) {
                    UserDefaults.standard.set(defaultAlertValue, forKey: "defaultAlertValue")
                }
            NotificationService.alertText()
                .fontWeight(.light)
        }
        .listRowStyle()
    }
    
    @ViewBuilder private var UserDataSettings: some View {
        Group {
            Button {
                viewModel.showImporter.toggle()
            } label: {
                Text("Import")
            }
            .buttonStyle(.plain)
            .fileImporter(
                isPresented: $viewModel.showImporter,
                allowedContentTypes: [.json]
            ) { result in
                viewModel.importFile(&userData.SuruItems, result)
            }
            
            Button {
                viewModel.exportFile(userData.SuruItems)
            } label: {
                Text("Export")
            }
            .buttonStyle(.plain)
            .fileExporter(
                isPresented: $viewModel.showExporter,
                document: viewModel.file,
                contentType: .json,
                defaultFilename: "SuruExport"
            ) { result in
                viewModel.exportHandler(result)
            }
        }
        .listRowStyle()
        .foregroundStyle(.black)
    }
}

#Preview {
    SettingsView(defaultAlertValue: .constant(false))
        .environment(UserData())
}
