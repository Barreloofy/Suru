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
    @State private var viewModel = ListViewModel()
    @FocusState private var focusedItem: UUID?
    
    var body: some View {
        NavigationStack {
            ZStack {
                DesignSystem.Colors.background.ignoresSafeArea()
                MainContent
                    .toolbar {
                        ToolbarItem(placement: .topBarLeading) { TitleContent }
                        ToolbarItemGroup(placement: .bottomBar) { ToolbarContent }
                    }
                    .toolbarStyle()
            }
            .bold()
            .foregroundStyle(DesignSystem.Colors.primary)
            .onLongPressGesture {
                focusedItem = nil
            }
        }
        .onChange(of: scenePhase) {
            guard scenePhase == .active else { return }
            NotificationService.shared.notificationAuthorization()
            NotificationService.shared.cleanup()
            Task {
                await NotificationService.shared.badgeUpdater()
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
                            SuruItemView(item: $item)
                                .listRowBackground(Color.clear)
                                .listRowSeparator(.hidden)
                                .focused($focusedItem, equals: item.id)
                                .swipeActions(edge: .trailing, allowsFullSwipe: false) {
                                    Button {
                                        userData.remove(item: item)
                                    } label: {
                                        Text("Delete")
                                    }
                                    .foregroundStyle(DesignSystem.Colors.background)
                                    .tint(DesignSystem.Colors.secondary)
                                }
                        }
                    }
                    .listStyle(.plain)
                    .scrollContentBackground(.hidden)
                    .animation(.default, value: userData.SuruItems)
                    .onChange(of: scenePhase) {
                        guard scenePhase == .active else { return }
                        viewModel.scrollToItem(proxy: proxy)
                    }
                    .onChange(of: userData.SuruItems) {
                        userData.update()
                    }
                    .onChange(of: userData.SuruItems.count) {
                        viewModel.scrollToItem(proxy: proxy, userData.SuruItems, userData.SuruItems.count - 1)
                    }
                }
            }
        }
    }
    
    
    @ViewBuilder private var ToolbarContent: some View {
        Button {
            focusedItem = userData.add()
        } label: {
            Text("New Suru")
        }
        
        Spacer()
        
        Button {
            viewModel.showSettings.toggle()
            focusedItem = nil
        } label: {
            Image(systemName: "gearshape.fill")
        }
        .sheet(isPresented: $viewModel.showSettings) {
            SettingsView()
        }
    }
    
    
    private var TitleContent: some View {
        Text("Suru")
            .font(.title)
    }
}

#Preview {
    ListView()
}
