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
            .listBackgroundStyle()
            .foregroundStyle(.black)
            .settingsError(
                "Import Error",
                isPresented: $viewModel.importError,
                actions: {
                    Button {
                        viewModel.importError.toggle()
                    } label: {
                        Text("Ok")
                    }
                }
            )
            .settingsError(
                "Export Error",
                isPresented: $viewModel.exportError,
                actions: {
                    Button {
                        viewModel.exportError.toggle()
                    } label: {
                        Text("Ok")
                    }
                }
            )
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                    }
                }
                
                ToolbarItem(placement: .principal) {
                    Text("Settings")
                        .font(.title)
                }
            }
        }
    }
    
    @ViewBuilder private var AlertSetting: some View {
        Group {
            Toggle("Alert", isOn: $defaultAlertValue)
                .tint(.autumnGreen)
                .opacity(NotificationService.shared.notificationPermission ? 1.0 : 0.25)
                .disabled(NotificationService.shared.notificationPermission ? false : true)
            NotificationService.shared.alertText()
                .fontWeight(.regular)
        }
        .rowStyle()
    }
    
    @ViewBuilder private var UserDataSettings: some View {
        Group {
            Button {
                viewModel.showImporter.toggle()
            } label: {
                Text("Import")
            }
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
            .fileExporter(
                isPresented: $viewModel.showExporter,
                document: viewModel.file,
                contentType: .json,
                defaultFilename: "SuruExport"
            ) { result in
                viewModel.exportHandler(result)
            }
        }
        .rowStyle()
        .buttonStyle(.plain)
    }
}

#Preview {
    SettingsView()
        .environment(UserData())
}
