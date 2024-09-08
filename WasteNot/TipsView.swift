//
//  TipsView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/28.
//

import SwiftUI

struct TipsView: View {
    @EnvironmentObject private var store: TipStore
    var didTapClose: () -> Void
    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Spacer()
                Button(action: didTapClose) {
                    Image(systemName: "xmark")
                        .symbolVariant(.circle.fill)
                        .font(.system(.largeTitle, design: .rounded).bold())
                        .symbolRenderingMode(.palette)
                        .foregroundStyle(.gray, .gray.opacity(0.2))
                }
            }
            
            Text("Enjoying the app so far? 👀")
                .font(.system(.title2, design: .rounded).bold())
                .multilineTextAlignment(.center)
            
            Text("If you'd like to support us, we’d really appreciate a tip. It helps us keep the app awesome and add more cool features.\n Any tips can remove Ads forever!")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .lineLimit(5)
                .minimumScaleFactor(0.5)
                .padding(.bottom, 16)
            
            ForEach(store.items) { item in
                TipsItemView(item: item)
            }
        }
        .padding(16)
        .background(Color("card-background"), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(8)
        .overlay(alignment: .top) {
            Image("appicon")
                .resizable()
                .scaledToFill()
                .frame(width: 80, height: 80)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .offset(y: -25)
        }
    }
}

#Preview {
    TipsView(didTapClose: {})
        .environmentObject(TipStore())
}
