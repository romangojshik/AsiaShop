//
//  ConfirmOrderView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct ConfirmOrderView: View {
    @StateObject private var viewModel: ConfirmOrderViewModel
    
    init(viewModel: ConfirmOrderViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 12) {
            Text("Подтверждение заказа")
                .font(.title2)
                .fontWeight(.bold)
            
            Text("Итоговая сумма: \(String(format: "%.2f", viewModel.totalCost)) руб")
                .font(.headline)
            
            Text("Вы точно хотите оформить заказ?")
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack(spacing: 16) {
                Button("Отмена") {
                    viewModel.cancelOrder()
                }
                .foregroundColor(.red)
                
                Button("Подтвердить") {
                    viewModel.confirmOrder()
                }
                .foregroundColor(.white)
                .padding()
                .background(Color.black)
                .cornerRadius(12)
            }
        }
        .padding(16)
    }
}
