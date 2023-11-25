//
//  PositionCell.swift
//  AsiaShop
//
//  Created by Roman on 11/24/23.
//

import SwiftUI

struct PositionCell: View {
    
    let position: Position
    
    var body: some View {
        
        HStack {
            Text(position.product.title)
                .fontWeight(.bold)
            
            Text("\(position.count) шт.")
            Spacer()
            Text(String(format: "%.2f", position.cost) + " руб")
                .frame(width: 85, alignment: .trailing)
        } .padding(.horizontal)
        
    }
}

struct PositionCell_Previews: PreviewProvider {
    static var previews: some View {
        PositionCell(position: Position(
            id: UUID().uuidString,
            product: Product(
                id: UUID().uuidString,
                title: "Суши с тунцом",
                imageURL: "tunec",
                price: 18.9,
                description: "тунец, водоросли нори, рис, васаби, имбирь маринованный, соус соевый, уксус рисовый"
            ),
            count: 3
        ))
    }
}
