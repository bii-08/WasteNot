//
//  ItemRowView.swift
//  WasteNot
//
//  Created by LUU THANH TAM on 2024/07/15.
//

import SwiftUI

struct ItemRowView: View {
    // MARK: - Property
    var item: Item
    
    var body: some View {
        HStack {
            // MARK: Item image
            if let uiImage = UIImage(data: item.image) {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: item.enumCaseString == nil ? .fill : .fit)
                    .frame(maxWidth: 85, maxHeight: item.enumCaseString == nil ? 105 : 85)
                    .cornerRadius(10)

            } else {
                Image(systemName: "photo")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: 85, maxHeight: 85)
            }
            
            // MARK: Item details
            VStack(alignment: .leading, spacing: 12) {
                Text(item.name)
                    .foregroundColor(.primary)
                    .font(.title3)
                    .fontWeight(.bold)
                
                HStack(spacing: 5) {
                 
                    Image(systemName: "calendar")
                        .foregroundColor(.primary)
                        
                    Text(item.expiryDate.formatted(date: .abbreviated, time: .omitted))
                        .font(.callout)
                       
                }
                Text("x \(item.quantity)")
                    .font(.headline)
                    .padding(3)
                    .background(.orange.opacity(0.2))
                    .clipShape(RoundedRectangle(cornerRadius: 5))
                    
            }
            .padding()
            HStack {
                Text("Expire in \n") +
                Text(" \(item.dayLeft)")
                    .foregroundColor(item.dayLeft > 0 ? .green : (item.dayLeft == 0 ? .orange : .red)) +
                Text(" days")
                    .font(.subheadline)
            }
        }
        .frame(minWidth: 325, maxWidth: .infinity)
        .padding(.horizontal)
        .background(Color("itemRow"))
        .cornerRadius(10)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: 5, y: 5)
        .shadow(color: Color.black.opacity(0.08), radius: 10, x: -5, y: -5)
    }
}

#Preview {
    ItemRowView(item: Item(name: "apple", quantity: 2, purchasedDate: Date.now, expiryDate: Date.now, image: Data(), enumCaseString: "apple"))
}
