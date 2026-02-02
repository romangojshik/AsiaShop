//
//  BasketView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct BasketView: View {
    @StateObject private var router = BasketRouter()
    @ObservedObject var viewModel: BasketViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBarView(title: "Корзина")
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 0) {
                    if viewModel.positions.isEmpty {
                        Spacer()
                        
                        VStack(spacing: 16) {
                            Text("Корзина пуста")
                                .font(.title2)
                                .foregroundColor(.secondary)
                            
                            Image("basket_empty")
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 90, height: 90)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.top, 50)
                        
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
            
            HStack {
                Text("ИТОГО:")
                    .fontWeight(.bold)
                Spacer()
                Text(String(format: "%.2f", viewModel.cost) + " руб")
                    .fontWeight(.bold)
            }.padding()
            
            
            Button(action: {
                router.navigate(to: .confirmOrder(totalCost: viewModel.cost))
            }) {
                Text("Оформить заказ")
                    .font(.body)
                    .fontWeight(.bold)
                    .foregroundColor(viewModel.positions.isEmpty ? .gray : .white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(viewModel.positions.isEmpty ? Color.gray.opacity(0.3) : Color(white: 0.15))
                    .cornerRadius(12)
            }
            .disabled(viewModel.positions.isEmpty)
            
            .sheet(item: $router.currentRoute) { route in
                switch route {
                case .confirmOrder(let totalCost):
                    ConfirmOrderView(
                        viewModel: ConfirmOrderViewModel(
                            totalCost: totalCost,
                            onConfirm: {
                                viewModel.createOrder()
                                router.dismiss()
                            },
                            onCancel: {
                                router.dismiss()
                            }
                        )
                    )
                }
            }
            .padding()
        }
        .navigationBarHidden(true)
    }
}
