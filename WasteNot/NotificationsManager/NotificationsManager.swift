//
//  NotificationsManager.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/21.
//

import Foundation
import UserNotifications
import SwiftData
import SwiftUI

class NotificationsManager: ObservableObject {
    
    @Published var setting: Setting {
        didSet {
            print("\(setting.notificationIsOn), \(setting.hour), \(setting.minute), \(setting.numsOfDayBefore)")
        }
    }
    private var modelContext: ModelContext
    
    init(modelContext: ModelContext) {
        self.modelContext = modelContext
        
        // Initialize currentTime with the provided hour and minute
        var components = DateComponents()
        components.hour = 8
        components.minute = 30
        let defaultTime = Calendar.current.date(from: components)
        
        self.setting = Setting(notificationIsOn: true, hour: 8, minute: 30, numsOfDayBefore: 3, currentTime: defaultTime!)
        
        fetchSetting()
        
    }
    
    static func askPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Access granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }
    
    func scheduleNotification(for item: Item) {
        guard setting.notificationIsOn else { return }
        
        var trigger: UNNotificationTrigger?
        
        // Subtract the number of days from the date
        if let alertDate = Calendar.current.date(byAdding: .day, value: -setting.numsOfDayBefore, to: item.expiryDate) {
            var dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: alertDate)
            dateComponents.hour = setting.hour
            dateComponents.minute = setting.minute
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Item Expiring Soon"
            content.body = "\(item.name) is expiring in \(item.dayLeft) days"
            content.sound = UNNotificationSound.default
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: trigger)
            
            UNUserNotificationCenter.current().add(request) { error in
                if let error = error {
                    print("Error adding notification: \(error.localizedDescription)")
                } else {
                    print("Notification scheduled successfully for \(item.name).")
                }
            }
            
        } else {
            print("There was an error calculating the new date.")
            return
        }
    }
    
    func cancelNotification() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("cancel notifications")
    }
    
    func fetchSetting() {
        let request = FetchDescriptor<Setting>()
        do {
            let data = try modelContext.fetch(request)
            if let first = data.first {
                self.setting = first
            } else {
                // Initialize currentTime with the provided hour and minute
                var components = DateComponents()
                components.hour = 8
                components.minute = 30
                let defaultTime = Calendar.current.date(from: components)
                let defaultSetting = Setting(notificationIsOn: true, hour: 8, minute: 30, numsOfDayBefore: 3, currentTime: defaultTime!)
                self.setting = defaultSetting
                modelContext.insert(defaultSetting)
            }
        } catch {
            print("Failed to fetch settings: \(error.localizedDescription)")
        }
    }
}
