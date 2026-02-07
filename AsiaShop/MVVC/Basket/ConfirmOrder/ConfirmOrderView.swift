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
        ScrollView {
            VStack(spacing: 16) {
                Text("Подтверждение заказа")
                    .font(.title2)
                    .fontWeight(.bold)
                
                Text("Итоговая сумма: \(String(format: "%.2f", viewModel.totalCost)) руб")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Введите ваше имя")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("Имя", text: $viewModel.userName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .autocapitalization(.words)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Введите номер телефона для подтверждения заказа")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    TextField("+375 (XX) XXX-XX-XX", text: $viewModel.phone)
                        .textFieldStyle(.roundedBorder)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Время приготовления")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    DatePicker(
                        "К какому времени приготовить ваш заказ",
                        selection: Binding(
                            get: { viewModel.readyBy ?? Date().addingTimeInterval(3600) },
                            set: { viewModel.readyBy = $0 }
                        ),
                        in: Date()...,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                }
                
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
}
