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
    @ObservedObject var notificationManager = NotificationsManager.shared
    @EnvironmentObject private var store: TipStore
    @State private var showTips = false
    @State private var showThanks = false
    @Query var items: [Item]
    var body: some View {
        NavigationStack {
            ZStack {
                
                List {
                    // Enable notifications
                    Section {
                        Toggle("Notifications", isOn: $notificationManager.setting.notificationIsOn)
                            .onChange(of: notificationManager.setting.notificationIsOn) { oldValue, newValue in
                                if newValue == false {
                                    Task {
                                       await notificationManager.cancelNotification()
                                    }
                                } else {
                                    // reschedule
                                    notificationManager.itemsToRechedule = items
                                    Task {
                                        await notificationManager.rescheduleNotification()
                                    }
                                }
                                print("Numbers of pending request: \(notificationManager.pendingRequests.count)")
                            }
                            .disabled(showThanks)
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
                                notificationManager.itemsToRechedule = items
                                
                                Task {
                                    await notificationManager.rescheduleNotification()
                                }
                            }
                            .disabled(showThanks)
                    } header: {
                        Text("Notification time")
                    }
                    .datePickerStyle(.compact)
                    .environment(\.locale, .init(identifier: "en"))
                    
                    // Send notification before ... days
                    Section {
                        Stepper("^[\(notificationManager.setting.numsOfDayBefore) day](inflect: true) before", value: $notificationManager.setting.numsOfDayBefore, in: 0...100)
                            .onChange(of: notificationManager.setting.numsOfDayBefore) { oldValue, newValue in
                                notificationManager.itemsToRechedule = items
                                Task {
                                    await notificationManager.rescheduleNotification()
                                }
                            }
                            .disabled(showThanks)
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
                            notificationManager.setting.numsOfDayBefore = 0
                            var components = DateComponents()
                            components.hour = 8
                            components.minute = 30
                            let defaultTime = Calendar.current.date(from: components)
                            notificationManager.setting.currentTime = defaultTime!
                            
                            notificationManager.itemsToRechedule = items
                            Task {
                                await notificationManager.rescheduleNotification()
                            }
                        }
                        .disabled(showThanks)
                    }
                    
                    Section {
                        
                        Button("Tip me") {
                            showTips.toggle()
                        }
                        .disabled(showThanks)
                        
                        
                    } footer: {
                        Text("")
                    }
                }
                .background(Color("background"))
                .scrollContentBackground(.hidden)
            }
            .navigationTitle(showTips ? "" : "Setting")
            .navigationBarBackButtonHidden(showThanks)
            .onAppear {
                Task {
                    await notificationManager.getPendingRequests()
                }
            }
            .overlay {
                if showTips {
                    Color.black.opacity(0.8)
                        .ignoresSafeArea()
                        .transition(.opacity)
                        .onTapGesture {
                            showTips.toggle()
                        }
                    TipsView {
                        showTips.toggle()
                    }
                    .environmentObject(store)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .overlay(alignment: .bottom) {
                if showThanks {
                    ThanksView {
                        showThanks = false
                    }
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                }
            }
            .animation(.spring(), value: showTips)
            .animation(.spring(), value: showThanks)
            .onChange(of: store.action) { oldValue, action in
                if action == .successful {
                    showTips = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        showThanks = true
                        store.reset()
                    }
                }
            }
            .alert(isPresented: $store.hasError, error: store.error) {}
        }
    }
}

#Preview {
    NavigationStack {
        
        SettingView(notificationManager: NotificationsManager.shared)
            .modelContainer(for: [Setting.self])
            .environmentObject(TipStore())
           
    }
}
