//
//  WidgetExtension.swift
//  WidgetExtension
//
//  Created by LUU THANH TAM on 2024/07/26.
//

import WidgetKit
import SwiftUI
import SwiftData

struct Provider: TimelineProvider {
    @MainActor func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), expiringItems: getNearExpiryItems())
    }

    @MainActor func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        let entry = SimpleEntry(date: Date(), expiringItems: getNearExpiryItems())
        completion(entry)
    }

    @MainActor func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        var entries: [SimpleEntry] = []

        let entry = SimpleEntry(date: .now, expiringItems: getNearExpiryItems())
            entries.append(entry)
        
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
    
    @MainActor
    private func getNearExpiryItems() -> [Item] {
        guard let modelContainer = try? ModelContainer(for: Item.self) else { return [] }
        var descriptor = FetchDescriptor<Item>()
        // 
        descriptor.fetchLimit = 5
        let expiringItems = try? modelContainer.mainContext.fetch(descriptor)
        print(expiringItems as Any)
        return expiringItems ?? []
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let expiringItems: [Item]
}

struct WidgetExtensionEntryView: View {
    var entry: Provider.Entry
    @Query private var items: [Item]
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        if family == .systemMedium || family == .systemLarge {
            HStack {
                if items.isEmpty {
                    ContentUnavailableView("No items", systemImage: "refrigerator.fill")
                } else {
                    // Item list
                    VStack(spacing: 0) {
                        HStack {
                            HStack {
                                Image(systemName: "alarm.fill")
                                    .foregroundColor(.gray)
                                Text("Expiring")
                            }
                            .bold()
                            
                            Spacer()
                        }
                        ForEach(entry.expiringItems.filter({$0.dayLeft >= 0})) { item in
                            HStack {
                                Text(item.name.capitalized)
                                Spacer()
                                
                                Text("^[\(item.dayLeft) day](inflect: true)")
                                    .padding(2)
                                    .background(RoundedRectangle(cornerRadius: 5).fill(.green.opacity(0.5)))
                                Spacer()
                            }
                            
                        }
                        Spacer()
                    }
                    
                    // Summary
                    HStack {
                        VStack {
                            ZStack {
                                Color.blue.opacity(0.8).cornerRadius(10)
                                VStack {
                                    Text("All")
                                    Text("\(items.count)")
                                }
                                .bold()
                                .foregroundColor(.white)
                                
                            }
                            
                            ZStack {
                                Color.orange.opacity(0.8).cornerRadius(10)
                                VStack {
                                    Text("Today")
                                    Text("\(items.filter({ $0.dayLeft == 0}).count)")
                                    
                                }
                                .bold()
                                .foregroundColor(.white)
                            }
                        }
                        
                        VStack {
                            ZStack {
                                Color.red.opacity(0.8).cornerRadius(10)
                                VStack {
                                    Text("Expired")
                                    Text("\(items.filter({ $0.dayLeft < 0}).count)")
                                }
                                .bold()
                                .foregroundColor(.white)
                            }
                            
                            ZStack {
                                Color.gray.opacity(0.2).cornerRadius(10)
                                Text("🪴")
                                    .bold()
                                    .font(.title)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
            }
            .navigationTitle("Near Expiry")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        } else {
            // Summary
            HStack {
                VStack {
                    ZStack {
                        Color.blue.opacity(0.8).cornerRadius(10)
                        VStack {
                            Text("All")
                            Text("\(items.count)")
                        }
                        .bold()
                        .foregroundColor(.white)
                        
                    }
                    
                    ZStack {
                        Color.orange.opacity(0.8).cornerRadius(10)
                        VStack {
                            Text("Today")
                            Text("\(items.filter({ $0.dayLeft == 0}).count)")
                            
                        }
                        .bold()
                        .foregroundColor(.white)
                    }
                }
                
                VStack {
                    ZStack {
                        Color.red.opacity(0.8).cornerRadius(10)
                        VStack {
                            Text("Expired")
                            Text("\(items.filter({ $0.dayLeft < 0}).count)")
                        }
                        .bold()
                        .foregroundColor(.white)
                    }
                    
                    ZStack {
                        Color.gray.opacity(0.2).cornerRadius(10)
                        Text("🪴")
                            .bold()
                            .font(.title)
                            .foregroundColor(.white)
                    }
                }
            }
            .navigationTitle("Near Expiry")
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
    }
}

struct WidgetExtension: Widget {
    let kind: String = "WidgetExtension"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetExtensionEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
            /// Setting up SwiftData Container
                .modelContainer(for: [Item.self, Setting.self])
            
        }
        .configurationDisplayName("Items")
        .description("This is an Near Expiry List.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

#Preview(as: .systemSmall) {
    WidgetExtension()
} timeline: {
    SimpleEntry(date: .now, expiringItems: [])
}
