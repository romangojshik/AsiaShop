//
//  BasketView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct BasketView: View {
    
    @ObservedObject var viewModel: BasketViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBarView(title: "Корзина")
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if viewModel.positions.isEmpty {
                        Spacer()
                        
                        Text("Корзина пуста")
                            .font(.title2)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                        
                        Spacer()
                    } else {
                        ForEach(Array(viewModel.positions.enumerated()), id: \.element.id) { index, position in
                            VStack(spacing: 0) {
                                HStack(spacing: 16) {
                                    Image(position.product.imageURL)
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 96, height: 96)
                                        .clipShape(RoundedRectangle(cornerRadius: 16))
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        HStack {
                                            Text(position.product.title)
                                                .font(.headline)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                        }
                                        
                                        Text(position.product.description)
                                            .font(.subheadline)
                                            .foregroundColor(.secondary)
                                            .multilineTextAlignment(.leading)
                                            .fixedSize(horizontal: false, vertical: true)
                                        
                                        HStack {
                                            Text(String(format: "%.2f руб", position.cost))
                                                .font(.subheadline)
                                                .foregroundColor(.secondary)
                                            
                                            Spacer()
                                            
                                            QuantityButton(
                                                count: position.count,
                                                onDecrease: {
                                                    viewModel.decreaseCount(positionId: position.id)
                                                },
                                                onIncrease: {
                                                    viewModel.increaseCount(positionId: position.id)
                                                }
                                            )
                                        }
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.vertical, 12)
                                
                                if index < viewModel.positions.count - 1 {
                                    Divider()
                                        .padding(.horizontal, 16)
                                }
                            }
                        }
                    }
                }
            }
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
                    var order = Order(
                        userID: AuthService.shared.currentUser!.uid,
                        date: Date(),
                        status: OrderStatus.new.rawValue
                    )
                    
                    order.positions = self.viewModel.positions
                    
                    DatabaseService.shared.setOrder(order: order) { result in
                        switch result {
                        case .success(let order):
                            print(order.cost)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }, label: {
                    Text("Заказать")
                        .font(.body)
                        .fontWeight(.bold)
                        .padding()
                        .foregroundColor(Color.white)
                        .background(Color.green)
                        .cornerRadius(24)
                })
                
            }.padding()
        }
        .navigationBarHidden(true)
    }
}
