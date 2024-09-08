//
//  HomeView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import SwiftUI
import SwiftData
import WidgetKit
import SwipeTammie

struct HomeView: View {
    // MARK: - Property
    @Environment(\.scenePhase) var scenePhase
    @Environment(\.modelContext) var modelContext
    @AppStorage("Tipped") private var shouldRemoveAds: Bool = false
    @State private var showingSetting = false
    @State private var showingAddEdit = false
    @State private var searchText = ""
    @State private var selectedItem: Item?
    @Query(sort: \Item.purchasedDate) var items: [Item]
    var filtered: [Item] {
        searchText.isEmpty ? items.sort(on: currentTab, items: items) : items.sort(on: currentTab, items: items).filter { $0.name.lowercased().contains(searchText.lowercased()) }
    }
    var tabs = ["All", "Near Expiry", "Expired"]
    @State private var currentTab = "All"
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                if NotificationsManager.shared.isGranted {
                    VStack {
                        expiryTabBar
                        
                        ScrollView {
                            if items.isEmpty {
                                ContentUnavailableView("No items", systemImage: "refrigerator.fill", description: Text("Tap on Plus button to add your items"))
                            } else {
                                itemsList
                            }
                        }
                        
                        Spacer()
                        
                        if !shouldRemoveAds {
                            BannerView()
                                .frame(height: 50)
                                .padding(.horizontal)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                        }
                    }
                    .toolbar {
                        // Header
                        ToolbarItem(placement: .topBarLeading) {
                            // Setting button
                            Button {
                                showingSetting = true
                            } label: {
                                Image(systemName: "gearshape.fill")
                                    .font(.title2)
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            // Plus button
                            Button {
                                showingAddEdit = true
                            } label: {
                                Image(systemName: "plus.app.fill")
                                    .font(.title2)
                                    .symbolEffect(.pulse)
                            }
                        }
                    }
                    .navigationDestination(isPresented: $showingSetting, destination: {
                        SettingView()
                    })
                    .navigationDestination(isPresented: $showingAddEdit, destination: {
                        AddEditView(selectedItem: $selectedItem)
                    })
                } else {
                    Button("Enable Notifications") {
                        NotificationsManager.shared.openSettings()
                    }
                    .buttonStyle(.bordered)
                }
            }
        }
        .onAppear {
            NotificationsManager.shared.fetchSetting(modelContext: modelContext)
        }
        .onChange(of: scenePhase) { _, newValue in
            if newValue == .active {
                Task {
                    await NotificationsManager.shared.getCurrentSettings()
                }
            }
            
            if newValue == .background {
                WidgetCenter.shared.reloadAllTimelines()
            }
        }
    }
}

// MARK: - Extension
extension HomeView {
    private var expiryTabBar: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button {
                    currentTab = tab
                } label: {
                    Text(tab)
                        .bold()
                        .foregroundColor(currentTab == tab ? .primary : .secondary)
                }
                
                if tab != tabs.last {
                    Spacer(minLength: 0)
                }
            }
        }
        .padding(.horizontal, 50)
    }
    
    private var itemsList: some View {
        ForEach(filtered) { item in
            ZStack {
                SwipeTammie(content: {
                    ItemRowView(item: item)
                }, leftActions: [],
                            rightActions: [
                    Action(title: "Edit", icon: "pencil", bgColor: .orange, fgColor: .white, cornerRadius: 10, action: {
                        selectedItem = item
                        showingAddEdit = true
                    }),
                    Action(title: "Delete", icon: "trash", bgColor: .red, fgColor: .white, cornerRadius: 10, action: {
                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                        withAnimation {
                            modelContext.delete(items[index])
                        }
                        // Cancel existing notification for the item
                        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [item.id.uuidString])
                        UNUserNotificationCenter.current().removeDeliveredNotifications(withIdentifiers: [item.id.uuidString])
                        print("Deleted the item and Canceled the pending notification")
                    }})], frameHeight: 100)
            }
            .listRowSeparator(.hidden)
            .padding(.horizontal)
            .padding(.top, item == filtered.first ? 10 : 0)
        }
        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Look for your item")
    }
}
extension [Item] {
    func sort(on tab: String, items: [Item]) -> [Item] {
        if tab == "All" {
            return items
        } else if tab == "Near Expiry" {
            return items.filter({ $0.dayLeft >= 0 && $0.dayLeft <= 7 })
        } else {
            return items.filter( {$0.dayLeft < 0 })
        }
    }
}

#Preview {
    HomeView()
        .modelContainer(for: [Item.self, Setting.self])
        
}
