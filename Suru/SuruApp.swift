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
    
    var body: some Scene {
        WindowGroup {
            ListView()
        }
    }
}
