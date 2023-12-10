//
//  OrderCell.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 11.12.23.
//

import SwiftUI

struct OrderCell: View {
    @State var order: Order = Order(userID: "", date: Date(), status: "Новый")
    
    var body: some View {
        HStack {
            Text("\(order.date)")
            Text("\(order.cost)")
                .bold()
                .frame(width: 90)
            Text("\(order.status)")
                .frame(width: 100)
                .foregroundColor(.green)
        }
    }
}

struct OrderCell_Previews: PreviewProvider {
    static var previews: some View {
        OrderCell()
    }
}
