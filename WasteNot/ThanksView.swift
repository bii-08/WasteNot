//
//  ThanksView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/28.
//

import SwiftUI

struct ThanksView: View {
    var didTapClose: () -> Void
    
    var body: some View {
        VStack(spacing: 8) {
            
            Text("Thank You 💕")
                .font(.system(.title2, design: .rounded).bold())
                .multilineTextAlignment(.center)
            
            Text("We appreciated your tip very much.")
                .font(.system(.body, design: .rounded))
                .multilineTextAlignment(.center)
                .padding(.bottom, 16)
            
            Button(action: didTapClose) {
                Text("Close")
                    .font(.system(.title3, design: .rounded).bold())
                    .tint(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.orange, in: RoundedRectangle(cornerRadius: 10,
                                                            style: .continuous))
            }
        }
        .padding(16)
        .background(Color("card-background"), in: RoundedRectangle(cornerRadius: 10, style: .continuous))
        .padding(.horizontal, 8)
    }
}

#Preview {
    ThanksView(didTapClose: {})
}
