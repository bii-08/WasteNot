//
//  HomeView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) var modelContext
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
    
    @GestureState var isDragging = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color("background").ignoresSafeArea()
                VStack {
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
                    
                    ScrollView {
                        ForEach(filtered) { item in
                            ZStack {
                                // Background (delete button)
                                Color.red.opacity(0.9)
                                    .cornerRadius(20)
//                                    .frame(minHeight: 115)
                                
                                // Background (edit button)
                                Color.orange.opacity(0.9)
                                    .cornerRadius(20)
                                    .padding(.trailing, 65)
//                                    .frame(minHeight: 115)
                                
                                HStack {
                                    Spacer()
                                    
                                    Button {
                                        selectedItem = item
                                        showingAddEdit = true
                                        
                                    } label: {
                                        VStack {
                                            Image(systemName: "pencil")
                                                .bold()
                                                .foregroundColor(.white)
                                                .frame(width: 65)
                                            Text("Edit")
                                                .bold()
                                                .foregroundColor(.white)
                                        }
                                    }
                                    
                                    Button {
                                        withAnimation {
                                            // Delete logics here
                                            if let index = items.firstIndex(where: { $0.id == item.id }) {
                                                modelContext.delete(items[index])
                                            }
                                        }
                                    } label: {
                                        VStack {
                                            Image(systemName: "trash.fill")
                                                .bold()
                                                .foregroundColor(.white)
                                                .frame(width: 65)
                                            Text("Delete")
                                                .bold()
                                                .foregroundColor(.white)
                                        }
                                    }
                                }
                                
                                ItemRowView(item: item)
                                    .offset(x: item.offset)
                                    .gesture(DragGesture().updating($isDragging, body: { (value, state, _) in
                                        state = true
                                        onChanged(value: value, item: item)
                                    }).onEnded({ (value) in
                                        onEnd(value: value, item: item)
                                    }))
                                
                            }
                            .listRowSeparator(.hidden)
                            .padding(.horizontal)
                            .padding(.top, item == filtered.first ? 10 : 0)
                            .onDisappear {
                                withAnimation {
                                    if let index = items.firstIndex(where: { $0.id == item.id }) {
                                        items[index].offset = 0
                                    }
                                }
                            }
                        }
                        .searchable(text: $searchText, placement: .navigationBarDrawer(displayMode: .always), prompt: "Look for your item")
                    }
                    
                    Spacer()
                    
                    BannerView()
                        .frame(height: 50)
                        .padding(.horizontal)
                        .clipShape(RoundedRectangle(cornerRadius: 5))
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
                        }
                    }
                    
                }
                .navigationDestination(isPresented: $showingSetting, destination: {
                    SettingView()
                })
                .navigationDestination(isPresented: $showingAddEdit, destination: {
                    AddEditView(selectedItem: $selectedItem)
                })
            }
        }
    }
    
    func onChanged(value: DragGesture.Value, item: Item) {
        if value.translation.width < 0 && isDragging {
            withAnimation {
                item.offset = value.translation.width
            }
        }
    }
    func onEnd(value: DragGesture.Value, item: Item) {
        withAnimation {
            if value.translation.width <= 50 {
                item.offset = -130
            } else {
                item.offset = 0
            }
            
        }
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
        .modelContainer(for: [Item.self])
        
}
