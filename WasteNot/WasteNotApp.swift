//
//  WasteNotApp.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import SwiftUI
import SwiftData
import GoogleMobileAds
import AdSupport
import AppTrackingTransparency
import UserNotifications

class AppDelegate: UIResponder, UIApplicationDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        requestPermission() // For tracking
        Task {
            await NotificationsManager.shared.askPermission() // For sending local notifications
        }
        return true
    }
    
    func requestPermission() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("Authorized")
                        print(ASIdentifierManager.shared().advertisingIdentifier)
                    case .denied:
                        print("Denied")
                    case .notDetermined:
                        // Tracking authorization dialog has not been shown
                        print("Not Determined")
                    case .restricted:
                        print("Restricted")
                    @unknown default:
                        print("Unknown")
                    }
                }
            }
        }
    }
}


@main
struct WasteNotApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    let modelContainer: ModelContainer
    @StateObject private var store = TipStore()
    init() {
        Task {
            await NotificationsManager.shared.getCurrentSettings()
        }
        do {
            modelContainer = try ModelContainer(for: Item.self, Setting.self)
        } catch {
            fatalError("Could not initialize ModelContainer")
        }
        // print the SQL file's path (SwiftData)
        print(URL.applicationSupportDirectory.path(percentEncoded: false))
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
                .environmentObject(store)
        }
        .modelContainer(modelContainer)
    }
}
