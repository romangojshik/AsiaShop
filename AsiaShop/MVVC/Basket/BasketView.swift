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
            
            ScreenContainer {
                VStack(spacing: 0) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            if viewModel.positions.isEmpty {
                                makeBasketEmptyView
                                Spacer()
                            } else {
                                makeBasketRowView
                            }
                        }
                    }
                    
                    if !viewModel.positions.isEmpty {
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
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(white: 0.15))
                                .cornerRadius(12)
                        }
                        .padding()
                    }
                }
            }
        }
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
        .navigationBarHidden(true)
    }
    
    private var makeBasketEmptyView: some View {
        VStack(spacing: 16) {
            Text("Вы еще ничего не заказали, ваша карзина пустая.")
                .font(.title2)
                .foregroundColor(Constants.Colors.blackOpacity70)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            Image(Constants.Images.basketEmpty)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .frame(width: 90, height: 90)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 100)
    }
    
    private var makeBasketRowView: some View {
        ForEach(Array(viewModel.positions.enumerated()), id: \.element.id) { index, position in
            VStack(spacing: 0) {
                BasketRowView(
                    basketViewModel: viewModel,
                    positionID: position.id
                )
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

private struct Constants {
    struct Images {
        static let basketEmpty = "basket_empty2"
    }
    
    struct Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
        static let blackOpacity90 = Color.black.opacity(0.9)
        
    }
}
