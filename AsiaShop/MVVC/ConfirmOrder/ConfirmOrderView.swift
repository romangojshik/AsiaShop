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
            VStack(spacing: Constants.Padding.padding24) {
                Text(Constants.Texts.confirmText)
                    .font(Constants.Fonts.titleFont)
                    .foregroundColor(Constants.Colors.blackOpacity90)
                
                Text("Итоговая сумма: \(String(format: "%.2f", viewModel.totalCost)) руб")
                    .font(.headline)
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Введите ваше имя")
                        .font(Constants.Fonts.titleTextFont)
                        .foregroundColor(Constants.Colors.blackOpacity90)
                    TextField("Имя", text: $viewModel.userName)
                        .textFieldStyle(.roundedBorder)
                        .textContentType(.name)
                        .autocapitalization(.words)
                }
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("Введите номер телефона для подтверждения заказа")
                        .font(Constants.Fonts.titleTextFont)
                        .foregroundColor(Constants.Colors.blackOpacity90)
                    TextField("+375 (XX) XXX-XX-XX", text: $viewModel.phone)
                        .keyboardType(.phonePad)
                        .textContentType(.telephoneNumber)
                        .padding(10)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(
                                    viewModel.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                    ? Color.red
                                    : Color.gray.opacity(0.4),
                                    lineWidth: 1
                                )
                        )
                }
                
                Spacer()
                
                makeDetaPickerSection
                
            }
            .padding(Constants.Padding.padding16)
        }
        makeConfirmSection
            .padding(.horizontal, Constants.Padding.padding16)
            .padding(.bottom, Constants.Padding.padding16)
    }
    
    private var makeDetaPickerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(Constants.Texts.detaPickerTitle)
                .font(Constants.Fonts.titleTextFont)
                .foregroundColor(Constants.Colors.blackOpacity90)
            HStack {
                Spacer()
                
                DatePicker(
                    "",
                    selection: Binding(
                        get: { viewModel.readyBy ?? Date().addingTimeInterval(3600) },
                        set: { viewModel.readyBy = $0 }
                    ),
                    in: Date()...,
                    displayedComponents: [.date, .hourAndMinute]
                )
                .labelsHidden()
                .datePickerStyle(.compact)
                .environment(\.locale, Constants.LocaleSettings.russian)
                
                Spacer()
            }
        }
    }
    
    private var makeConfirmSection: some View {
        VStack {
            Text(Constants.Texts.confirmTitle)
                .font(.body)
                .foregroundColor(.secondary)
            
            HStack(spacing: Constants.Padding.padding16) {
                WhiteOrBlackButton(
                    title: Constants.Texts.cancel,
                    backgroundColor: Constants.Colors.blackOpacity90,
                    foregroundColor: .white,
                    action: {
                        viewModel.cancelOrder()
                    }
                )
                
                WhiteOrBlackButton(
                    title: Constants.Texts.confirm,
                    backgroundColor: Constants.Colors.blackOpacity90,
                    foregroundColor: .white,
                    action: {
                        viewModel.confirmOrder()
                    }
                )
                .disabled(viewModel.phone.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
        }
    }
}


// MARK: - Constants

private struct Constants {
    struct Images {}
    
    struct Texts {
        static let confirmText = "Подтверждение заказа"
        static let detaPickerTitle = "К какому времени приготовить ваш заказ"
        static let confirmTitle = "Вы хотите оформить заказ?"
        static let cancel = "Отмена"
        static let confirm = "Подтвердить"
    }
    
    struct Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
        static let blackOpacity90 = Color.black.opacity(0.9)
    }
    
    struct Fonts {
        static let titleFont = SwiftUI.Font.system(size: 20, weight: .bold)
        static let titleDescriptionFont = SwiftUI.Font.system(size: 14, weight: .semibold)
        static let titleTextFont = SwiftUI.Font.system(size: 16, weight: .medium)
    }
    
    struct Padding {
        static let padding16 = 16.0
        static let padding24 = 24.0
        static let padding32 = 32.0
    }
    
    struct LocaleSettings {
        static let russian = Locale(identifier: "ru_RU")
    }
}

// MARK: - Preview

#Preview {
    ConfirmOrderView(
        viewModel: ConfirmOrderViewModel(
            totalCost: 49.8,
            onConfirm: { userName, phone, readyBy in
                print("Confirm order for \(userName), phone: \(phone), readyBy: \(readyBy?.description ?? "nil")")
            },
            onCancel: {
                print("Cancel order")
            }
        )
    )
}
