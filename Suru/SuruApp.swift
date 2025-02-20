//
//  SuruApp.swift
//  Suru
//
//  Created by Barreloofy on 10/23/24 at 12:21 AM.
//

@preconcurrency import SwiftUI

@main
struct SuruApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ListView()
                .onChange(of: scenePhase) {
                    guard scenePhase == .active else { return }
#warning("More rfactoring needed")
                    for element in NotificationService.shared.firstTimeRepeatingNotifications {
                        guard element.dueDate < Date() else { return }
                        Task {
                            await NotificationService.shared.createRepeatingNotification(for: element)
                        }
                    }
                    Task {
                        let pendingNotificationRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
                        pendingNotificationRequests.forEach {
                            guard let trigger = $0.trigger as? UNCalendarNotificationTrigger else { return }
                            guard let nextDate = trigger.nextTriggerDate() else { return }
                            print(Calendar.current.dateComponents(in: TimeZone(abbreviation: "CET")!, from: nextDate))
                            print("Raw nextTriggerDate: \(nextDate)")
                        }
                        print(NotificationService.shared.firstTimeRepeatingNotifications)
                    }
                }
        }
    }
}
