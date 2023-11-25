//
//  BasketView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct BasketView: View {
    
    @StateObject var viewModel: BasketViewModel
    
    var body: some View {
        
        VStack {
            List(viewModel.positions) { position in
                PositionCell(position: position)
            }
            
            .listStyle(PlainListStyle())
            .navigationTitle("Корзина")
            
            HStack {
                Text("ИТОГО:")
                    .fontWeight(.bold)
                Spacer()
                Text(String(format: "%.2f", viewModel.cost) + " руб")

                    .fontWeight(.bold)
            }.padding()
            
            
            HStack(spacing: 25) {
                Button(action: {
                    print("Отменить")
                }, label: {
                    Text("Отменить")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.red)
                        .cornerRadius(24)
                })
                
                Button(action: {
                    print("Заказать")
                }, label: {
                    Text("Заказать")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .cornerRadius(24)
//                        .frame(maxWidth: .infinity)
                })
                
            }.padding()
        }
    }
}

struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView(viewModel: BasketViewModel.shared)
    }
}
