//
//  SettingView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import SwiftUI
import SwiftData

struct SettingView: View {
    @Environment(\.modelContext) var modelContext
    @ObservedObject var notificationManager: NotificationsManager
    
    var body: some View {
        NavigationStack {
            ZStack {
                
                List {
                    // Enable notifications
                    Section {
                        Toggle("Notifications", isOn: $notificationManager.setting.notificationIsOn)
                            .onChange(of: notificationManager.setting.notificationIsOn) { oldValue, newValue in
                                if newValue == false {
                                    notificationManager.cancelNotification()
                                }
                            }
                    } header: {
                        Text("Notifications enable")
                    } footer: {
                        Text("Get notifications when items nearly expiry")
                    }
                    
                    // Remind me at
                    Section {
                        DatePicker("Remind me at", selection: $notificationManager.setting.currentTime, displayedComponents: .hourAndMinute)
                            .onChange(of: notificationManager.setting.currentTime) { oldValue, newValue in
                                let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
                                notificationManager.setting.hour = Int(components.hour ?? 8)
                                notificationManager.setting.minute = Int(components.minute ?? 30)
                            }
                    } header: {
                        Text("Notification time")
                    }
                    .datePickerStyle(.compact)
                    .environment(\.locale, .init(identifier: "en"))
                    
                    // Send notification before ... days
                    Section {
                        Stepper("^[\(notificationManager.setting.numsOfDayBefore) day](inflect: true) before", value: $notificationManager.setting.numsOfDayBefore, in: 1...100)
                    } header: {
                        Text("Expiry Reminder")
                    } footer: {
                        Text("Notifications will be sent this many days before the item expires")
                    }
                    
                    // Reset to default settings
                    Section {
                        Button("Reset Settings") {
                            notificationManager.setting.notificationIsOn = true
                            notificationManager.setting.hour = 8
                            notificationManager.setting.minute = 30
                            notificationManager.setting.numsOfDayBefore = 3
                            var components = DateComponents()
                            components.hour = 8
                            components.minute = 30
                            let defaultTime = Calendar.current.date(from: components)
                            notificationManager.setting.currentTime = defaultTime!
                        }
                    }
                }
                .background(Color("background"))
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Setting")
           
        }
    }
}

//#Preview {
//    NavigationStack {
//        SettingView(notificationManager: <#NotificationsManager#>)
//            .modelContainer(for: [Setting.self])
//           
//    }
//}
