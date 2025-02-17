//
//  ListView.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:24 AM.
//

import SwiftUI

struct ListView: View {
    @Environment(\.scenePhase) private var scenePhase
    @State private var userData = UserData()
    @State private var showSettings = false
    @State private var defaultAlertValue = UserDefaults.standard.bool(forKey: "defaultAlertValue")
    @State private var date = Date()
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.pastelGray).ignoresSafeArea()
                MainContent
                    .toolbar {
                        ToolbarItemGroup(placement: .bottomBar) {
                            ToolbarContent
                        }
                        ToolbarItem(placement: .topBarLeading) {
                            Text("Suru")
                                .font(.title)
                        }
                    }
                    .toolbarStyle()
            }
            .bold()
            .foregroundStyle(.autumnOrange)
        }
        .onAppear {
            NotificationService.notificationAuthorization()
            NotificationService.setDefaultAlertValue(&defaultAlertValue)
        }
        .onChange(of: userData.SuruItems) {
            userData.update()
        }
        .onChange(of: scenePhase) {
            guard scenePhase == .active else { return }
            date = Date()
            NotificationService.cleanup()
            Task {
                await NotificationService.badgeUpdater()
            }
        }
        .environment(userData)
    }
    
    
    @ViewBuilder private var MainContent: some View {
        VStack {
            if userData.SuruItems.isEmpty {
                Text("eeeeeeeto")
                    .font(.title)
                    .bold()
            }
            else {
                List {
                    ForEach($userData.SuruItems) { $item in
                        SuruItemView(item: $item, date: $date)
                            .listRowBackground(Color.clear)
                            .listRowSeparator(.hidden)
                    }
                    .onDelete { IndexSet in
                        userData.remove(IndexSet)
                    }
                }
                .listStyle(.plain)
                .scrollContentBackground(.hidden)
            }
        }
    }
    
    
    @ViewBuilder private var ToolbarContent: some View {
        Button {
            guard defaultAlertValue else {
                userData.SuruItems.append(SuruItem())
                return
            }
            userData.SuruItems.append(SuruItem(alert: true))
        } label: {
            Text("New Suru")
        }
        
        Spacer()
        
        Button {
            showSettings.toggle()
        } label: {
            Image(systemName: "gearshape.fill")
        }
        .sheet(isPresented: $showSettings) {
            SettingsView(defaultAlertValue: $defaultAlertValue)
        }
    }
}

#Preview {
    ListView()
}
