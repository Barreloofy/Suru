//
//  AppDelegate.swift
//  Suru
//
//  Created by Barreloofy on 2/18/25 at 8:18 PM.
//

import UIKit
import UserNotifications
import OSLog

class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate {
    private var completedItems = UserDefaults.standard.stringArray(forKey: "completedItems") {
        didSet {
            UserDefaults.standard.set(completedItems, forKey: "completedItems")
        }
    }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        NotificationService.shared.setupNotificationCategories()
        return true
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse) async {
        
        switch response.actionIdentifier {
            case "CompleteAction":
                completedItems?.append(response.notification.request.identifier)
            default:
                Logger().error("Unknown actionIdentifier")
        }
        
        var notificationID = response.notification.request.identifier
        if notificationID.hasSuffix("_repeating") {
            Task {
                notificationID = String(notificationID.dropLast(10))
                NotificationService.shared.tappedNotification = notificationID
                await NotificationService.shared.createRepeatingNotification(response.notification, notificationID)
            }
        }
        else {
            NotificationService.shared.tappedNotification = notificationID
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification) async -> UNNotificationPresentationOptions {
        var notificationID = notification.request.identifier
        if notificationID.hasSuffix("_repeating") {
            Task {
                notificationID = String(notificationID.dropLast(10))
                NotificationService.shared.tappedNotification = notificationID
                await NotificationService.shared.createRepeatingNotification(notification, notificationID)
            }
        }
        return []
    }
}
