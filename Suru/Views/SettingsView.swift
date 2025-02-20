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
    @AppStorage("defaultAlertValue") private var defaultAlertValue = false
    
    var body: some View {
        NavigationStack {
            Form {
                AlertSetting
                UserDataSettings
            }
            .scrollContentBackground(.hidden)
            .background(.pastelGray)
            .foregroundStyle(.black)
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
                .bold()
                .foregroundStyle(.black)
                .tint(.autumnGreen)
                .opacity(NotificationService.shared.notificationPermission ? 1.0 : 0.25)
                .disabled(NotificationService.shared.notificationPermission ? false : true)
            NotificationService.shared.alertText()
                .fontWeight(.regular)
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
    }
}

#Preview {
    SettingsView()
        .environment(UserData())
}
