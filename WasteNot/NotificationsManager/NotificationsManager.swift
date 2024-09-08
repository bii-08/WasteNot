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

@MainActor
class NotificationsManager: ObservableObject {
    // MARK: - Property
    static let shared = NotificationsManager()
    
    @Published var setting: Setting {
        didSet {
            print("\(setting.notificationIsOn), \(setting.hour), \(setting.minute), \(setting.numsOfDayBefore)")
        }
    }
    
    @Published var pendingRequests: [UNNotificationRequest] = []
    @Published var isGranted = false
    
    var itemsToRechedule: [Item] = []
    private var modelContext: ModelContext?
    
    // MARK: - Initializer
    init() {

        // Initialize currentTime with the provided hour and minute
        var components = DateComponents()
        components.hour = 8
        components.minute = 30
        let defaultTime = Calendar.current.date(from: components)
        
        self.setting = Setting(notificationIsOn: true, hour: 8, minute: 30, numsOfDayBefore: 3, currentTime: defaultTime!)
    }
    
    // MARK: - Functions
   func askPermission() async {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                self.isGranted = true
                print("Access granted!")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
        await getCurrentSettings()
    }
    
func getCurrentSettings() async {
        let currentSettings = await UNUserNotificationCenter.current().notificationSettings()
        if currentSettings.authorizationStatus == .authorized {
            self.isGranted = true
        } else {
            self.isGranted = false
        }
    }
    
    func scheduleNotification(for item: Item) async {
        guard setting.notificationIsOn else { return }
        
        // Cancel existing notification for the item
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
        
        var trigger: UNNotificationTrigger?
        
        // Subtract the number of days from the date
        if let alertDate = Calendar.current.date(byAdding: .day, value: -setting.numsOfDayBefore, to: item.expiryDate) {
            var dateComponents = Calendar.current.dateComponents([.day, .month, .year, .hour, .minute], from: alertDate)
            dateComponents.hour = setting.hour
            dateComponents.minute = setting.minute
            trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = "Waste Not!"
            content.body = "\(item.name) is expiring in \(item.dayLeft) days."
            content.sound = UNNotificationSound.default
           
            if let image = UIImage(data: item.image),
               let resizedImageData = resizeAndConvertImage(image),
               let attachment = try? UNNotificationAttachment(identifier: UUID().uuidString, url: saveImageToDisk(data: resizedImageData), options: nil) {
                content.attachments = [attachment]
            }
            
            let request = UNNotificationRequest(
                identifier: item.id.uuidString,
                content: content,
                trigger: trigger)
            
            do {
                try await UNUserNotificationCenter.current().add(request)
                await getPendingRequests()
                print("Notification scheduled successfully for \(item.name).")
            } catch {
                print("Error adding notification: \(error.localizedDescription)")
            }
            
        } else {
            print("There was an error calculating the new date.")
            return
        }
    }
    
    func cancelNotification() async {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
        print("cancel notifications")
        await getPendingRequests()
    }
    
    func rescheduleNotification() async {
        // Schedule notifications for itemsToReschedule
        for item in itemsToRechedule {
            await scheduleNotification(for: item)
        }
        await getPendingRequests()
        itemsToRechedule.removeAll()
    }
    
    func fetchSetting(modelContext: ModelContext) {
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
    // Resize the image
    func resizeAndConvertImage(_ image: UIImage, maxSize: CGFloat = 1024) -> Data? {
        let size = image.size
        let aspectRatio = size.width / size.height
        
        var newSize: CGSize
        if aspectRatio > 1 {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage?.jpegData(compressionQuality: 0.8) // Convert to JPEG with 80% quality
    }
    
    // Save the Image to a Temporary File URL
    private func saveImageToDisk(data: Data) -> URL {
        let fileManager = FileManager.default
        let tempDirectory = fileManager.temporaryDirectory
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = tempDirectory.appendingPathComponent(fileName)
        
        do {
            try data.write(to: fileURL)
            print("--> \(fileURL)")
        } catch {
            print("Error saving image to disk: \(error.localizedDescription)")
        }
        
        return fileURL
    }
    
   func getPendingRequests() async {
        pendingRequests = await UNUserNotificationCenter.current().pendingNotificationRequests()
        print("Numbers of pending request: \(pendingRequests.count)")
        for request in pendingRequests {
            print("Pending notification: \(request.identifier), title: \(request.content.title), body: \(request.content.body)")
        }
    }
    
    func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            if UIApplication.shared.canOpenURL(url) {
                Task {
                    await UIApplication.shared.open(url)
                }
            }
        }
    }
}
