//
//  BasketView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct BasketView: View {
    @StateObject private var router = BasketRouter()
    @EnvironmentObject var storage: OrderDataStorage
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavigationBarView(title: "Корзина")
            
            ScreenContainer {
                if storage.positions.isEmpty {
                    VStack {
                        Spacer()
                        
                        makeBasketEmptyView
                        
                        Spacer()
                    }
                } else {
                    VStack(spacing: 0) {
                        ScrollView(.vertical, showsIndicators: false) {
                            VStack(spacing: 0) {
                                makeBasketRowView
                                ForEach(ExtraButton.stepperExtras, id: \.self) { extra in
                                    BasketExtraRowView(extraButton: extra)
                                }
                                makeTotalView
                            }
                        }
                    }
                }
            }
        }
        .sheet(item: $router.currentRoute) { route in
            Group {
                if #available(iOS 16.4, *) {
                    sheetView(for: route)
                        .presentationDetents([.large])
                        .presentationDragIndicator(.visible)
                        .presentationBackground(Color.white)
                } else {
                    sheetView(for: route)
                }
            }
        }
        .navigationBarHidden(true)
    }
    
    private var makeBasketEmptyView: some View {
        VStack(spacing: 16) {
            Text(Constants.Texts.emptyBasketMessage)
                .font(.title2)
                .foregroundColor(AppConstants.Colors.blackOpacity70)
                .multilineTextAlignment(.center)
                .frame(maxWidth: 300)
            
            LottieView(name: "Empty Cart", loopMode: .playOnce)
                .frame(width: 90, height: 90)
        }
        .frame(maxWidth: .infinity)
    }
    
    private var makeBasketRowView: some View {
        ForEach(Array(storage.positions.enumerated()), id: \.element.id) { index, position in
            VStack(spacing: 0) {
                BasketRowView(
                    positionID: position.id
                )
                .padding(.horizontal)
                .padding(.vertical, 12)
                
                if index < storage.positions.count {
                    Divider()
                        .padding(.horizontal, 16)
                }
            }
        }
    }
    
    @ViewBuilder
    private var makeTotalView: some View {
        if !storage.positions.isEmpty {
            HStack {
                Text(Constants.Texts.total)
                    .fontWeight(.bold)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                Spacer()
                Text(String(format: "%.2f", storage.totalCost) + " руб")
                    .fontWeight(.bold)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
            }.padding()
            
            WhiteOrBlackButton(
                title: Constants.Texts.placeOrder,
                backgroundColor: Color(white: 0.15),
                foregroundColor: .white,
                action: {
                    router.navigate(to: .confirmOrder(totalCost: storage.totalCost))
                }
            )
            .padding()
        }
    }
    
    @ViewBuilder
    private func sheetView(for route: BasketRoute) -> some View {
        switch route {
        case .confirmOrder(let totalCost):
            ConfirmOrderView(
                viewModel: ConfirmOrderViewModel(
                    totalCost: totalCost,
                    positions: storage.positions,
                    getTotalCost: { storage.totalCost },
                    extras: storage.makeExtrasString(),
                    onOrderCreated: { userPhone in
                        router.navigate(to: .orderAccepted(userPhone: userPhone))
                    },
                    onCancel: {
                        router.dismiss()
                    },
                    clearBasket: { storage.clearBasket() }
                )
            )
            
        case .orderAccepted:
            OrderAcceptedView(
                viewModel: OrderAcceptedViewModel(
                    userPhoneNumber: "",
                    onOk: {
                        router.dismiss()
                    }
                )
            )
        }
    }
    
}

private struct Constants {
    struct Images {
        static let basketEmpty = "basket_empty2"
    }
    
    
    struct Texts {
        static let emptyBasketMessage = "Вы еще ничего не заказали, ваша карзина пустая."
        static let total = "ИТОГО:"
        static let placeOrder = "Оформить заказ"
    }
}
