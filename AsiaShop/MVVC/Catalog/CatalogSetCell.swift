//
//  CatalogProductCell.swift
//  AsiaShop
//
//  Created by AI on request.
//

import SwiftUI

struct CatalogSetCell: View {
    let sushiSet: SushiSet
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                Image(sushiSet.imageURL)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: screen.width * 0.3, height: screen.width * 0.3)
                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                
                Button {
                    let position = Position(
                        id: UUID().uuidString,
                        product: sushiSet.toProduct(),
                        count: 1
                    )
                    BasketViewModel.shared.addPosition(position: position)
                } label: {
                    Image(systemName: "plus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.black)
                        .frame(width: 30, height: 30)
                        .background(Color.white)
                        .clipShape(Circle())
                        .shadow(color: Color.black.opacity(0.15), radius: 3, x: 0, y: 2)
                }
                .padding(6)
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(sushiSet.toProduct().title)
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(2)
                
                HStack {
                    Text(String(format: "%.0fруб/сет", sushiSet.toProduct().price))
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.black.opacity(0.9))
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                    
                    Spacer()
                }
                
                Text(sushiSet.toProduct().weight ?? "")
                    .font(.system(size: 13, weight: .semibold))
                    .lineLimit(1)
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 4)
        }
    }
}

//struct CatalogSetCell_Previews: PreviewProvider {
//    static var previews: some View {
//        CatalogSetCell(
//            sushiSet: SushiSet(
//                id: "1",
//                name: "Асами",
//                description: "Описание сета",
//                imageName: "asami",
//                price: 65.0,
//                numberOfPieces: 32
//            )
//        )
//        .padding()
//        .background(Color.gray.opacity(0.2))
//    }
//}

