//
//  AppDelegate.swift
//  Suru
//
//  Created by Barreloofy on 2/18/25 at 8:18 PM.
//

import UIKit
import SwiftUI
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate {
    var viewRouter: ViewRouter?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        let notificationID = response.notification.request.identifier
        viewRouter!.rowID = notificationID
    }
}

@MainActor
@Observable
final class ViewRouter {
    var rowID: String?
}
