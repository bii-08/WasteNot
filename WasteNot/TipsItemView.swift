//
//  TipsItemView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/28.
//

import SwiftUI
import StoreKit

struct TipsItemView: View {
    @EnvironmentObject private var store: TipStore
    let item: Product?
    
    var body: some View {
        HStack {
            
            VStack(alignment: .leading,
                   spacing: 3) {
                Text(item?.displayName ?? "-")
                    .font(.system(.title3, design: .rounded).bold())
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                Text(item?.description ?? "-")
                    .font(.system(.callout, design: .rounded).weight(.regular))
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            
            Spacer()
            
            Button(item?.displayPrice ?? "-") {
                if let item = item {
                    Task {
                        await store.purchase(item)
                    }
                }
            }
            .tint(.blue)
            .buttonStyle(.bordered)
            .font(.callout.bold())
        }
        .padding(16)
        .background(Color(UIColor.systemBackground),
                    in: RoundedRectangle(cornerRadius: 10, style: .continuous))
    }
}

#Preview {
    TipsItemView(item: nil)
        .environmentObject(TipStore())
}
