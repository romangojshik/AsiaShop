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
                    .padding(.top, Constants.Padding.padding16)
                
                Text("Итоговая сумма: \(String(format: "%.2f", viewModel.totalCost)) руб")
                    .font(Constants.Fonts.titleFont)
                    .foregroundColor(Constants.Colors.blackOpacity90)
                
                
                makeInputField(
                    title: Constants.Texts.enterUserName,
                    placeholder: Constants.Texts.namePlaceholder,
                    text: $viewModel.userName,
                    textContentType: .name
                )
                                
                makeInputField(
                    title: Constants.Texts.enterUserPhone,
                    placeholder: Constants.Texts.userPhonePlaceholder,
                    text: $viewModel.phone,
                    textContentType: .telephoneNumber,
                    keyboardType: .phonePad,
                    validateEmpty: true,
                    showValidationError: viewModel.showPhoneValidationError
                )
                
                makeDetaPickerSection
                
                makeConfirmSection
            }
            .padding(Constants.Padding.padding16)
        }
        .padding(.bottom, Constants.Padding.padding16)
    }
    
    private func makeInputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        textContentType: UITextContentType,
        keyboardType: UIKeyboardType = .default,
        validateEmpty: Bool = false,
        showValidationError: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: Constants.Padding.padding16) {
            Text(title)
                .font(Constants.Fonts.titleTextFont)
                .foregroundColor(Constants.Colors.blackOpacity90)
            
            TextField(placeholder, text: text)
                .foregroundColor(Constants.Colors.blackOpacity90)
                .tint(Constants.Colors.blackOpacity90)
                .padding(Constants.Padding.padding10)
                .background(Color.white)
                .keyboardType(keyboardType)
                .textContentType(textContentType)
                .overlay(
                    RoundedRectangle(cornerRadius: Constants.Padding.padding8)
                        .stroke(
                            validateEmpty && showValidationError && text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.red
                                : .black,
                            lineWidth: 1
                        )
                )
        }
    }
    
    private var makeDetaPickerSection: some View {
        VStack(alignment: .leading, spacing: Constants.Padding.padding8) {
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
        VStack(spacing: Constants.Padding.padding12) {
            Text(Constants.Texts.confirmTitle)
                .font(Constants.Fonts.titleTextFont)
                .foregroundColor(Constants.Colors.blackOpacity90)
            
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
        static let enterUserName = "Введите ваше имя"
        static let namePlaceholder = "Имя"
        static let enterUserPhone = "Введите номер телефона для подтверждения заказа *"
        static let userPhonePlaceholder = "+375 (XX) XXX-XX-XX"
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
        static let padding8 = 8.0
        static let padding10 = 10.0
        static let padding12 = 12.0
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
            positions: [],
            onOrderCreated: { _ in },
            onCancel: {},
            clearBasket: {}
        )
    )
}
