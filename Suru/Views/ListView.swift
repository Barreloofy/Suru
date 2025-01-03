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
                Color.pastelGray
                    .ignoresSafeArea()
                
                Group {
                    if userData.SuruItems.isEmpty {
                        Text("eeeeeeeto")
                            .font(.title)
                            .bold()
                    } else {
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
                        .onChange(of: userData.SuruItems) {
                            userData.sortSuruItems()
                        }
                    }
                }
                
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Button("New Suru") {
                            if defaultAlertValue {
                                userData.SuruItems.append(SuruItem(alert: true))
                            } else {
                                userData.SuruItems.append(SuruItem())
                            }
                        }
                        .tint(.autumnOrange)
                        .bold()
                        
                        Spacer()
                        
                        Button {
                            showSettings.toggle()
                        } label: {
                            Image(systemName: "gearshape.fill")
                        }
                        .tint(.autumnOrange)
                        .sheet(isPresented: $showSettings) {
                            SettingsView(defaultAlertValue: $defaultAlertValue)
                        }
                    }
                    
                    ToolbarItem(placement: .topBarLeading) {
                        Text("Suru")
                            .foregroundStyle(.autumnOrange)
                            .font(.title)
                            .bold()
                    }
                }
                .toolbarBackgroundVisibility(.automatic, for: .navigationBar)
                .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
                .toolbarBackgroundVisibility(.visible, for: .bottomBar)
                .toolbarBackground(.ultraThinMaterial, for: .bottomBar)
            }
        }
        .environment(userData)
        .onAppear {
            NotificationService.notificationAuthorization()
            NotificationService.setDefaultAlertValue(&defaultAlertValue)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active {
                NotificationService.scheduleRepeatingNotification(userData.SuruItems)
                NotificationService.clearNotifications()
                date = Date()
            }
        }
    }
}

#Preview {
    ListView()
}
