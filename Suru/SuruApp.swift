//
//  SuruApp.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:21 AM.
//

import SwiftUI

@main
struct SuruApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @State private var viewRouter = ViewRouter()
    
    var body: some Scene {
        WindowGroup {
            ListView()
                .environment(viewRouter)
                .onAppear {
                    appDelegate.viewRouter = viewRouter
                }
        }
    }
}
