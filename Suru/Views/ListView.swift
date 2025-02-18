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
    @FocusState private var focusedItem: UUID?
    
    @Environment(ViewRouter.self) private var viewRouter
    
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
                ScrollViewReader { proxy in
                    List {
                        ForEach($userData.SuruItems) { $item in
                            SuruItemView(item: $item, date: $date)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .focused($focusedItem, equals: item.id)
                                .id(item.id)
                        }
                        .onDelete { IndexSet in
                            userData.remove(IndexSet)
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .onAppear {
                        guard let str = viewRouter.rowID, let id = UUID(uuidString: str) else {
                            print("Error")
                            return
                        }
                        focusedItem = id
                        proxy.scrollTo(id, anchor: .center)
                    }
                    .onChange(of: userData.SuruItems.count) {
                        guard let id = focusedItem else { return }
                        proxy.scrollTo(id)
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder private var ToolbarContent: some View {
        Button {
            if defaultAlertValue {
                userData.SuruItems.append(SuruItem(alert: true))
            }
            else {
                userData.SuruItems.append(SuruItem())
            }
            focusedItem = userData.SuruItems.last?.id
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
