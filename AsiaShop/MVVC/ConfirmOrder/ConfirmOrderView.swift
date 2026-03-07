//
//  ConfirmOrderView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

struct ConfirmOrderView: View {
    @ObservedObject var viewModel: ConfirmOrderViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Padding.padding24) {
                Text(Constants.Texts.confirmText)
                    .font(.titleFont)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                    .padding(.top, AppConstants.Padding.padding16)
                
                Text(String.totalCost(viewModel.totalCost))
                    .font(.titleFont)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                
                
                makeInputField(
                    title: Constants.Texts.enterUserName,
                    placeholder: Constants.Texts.namePlaceholder,
                    text: $viewModel.userName,
                    textContentType: .name,
                    validateEmpty: true,
                    showValidationError: viewModel.showNameValidationError
                )
                                
                makePhoneInputField(
                    title: Constants.Texts.enterUserPhone,
                    placeholder: Constants.Texts.userPhonePlaceholder,
                    text: $viewModel.phone,
                    validateEmpty: true,
                    showValidationError: viewModel.showPhoneValidationError
                )
                
                makeDetaPickerSection
                
                makeConfirmSection
            }
            .padding(AppConstants.Padding.padding16)
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .padding(.bottom, AppConstants.Padding.padding16)
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
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding16) {
            Text(title)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .padding(AppConstants.Padding.padding10)
                        .allowsHitTesting(false)
                }
                TextField("", text: text)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                    .tint(.black)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .padding(AppConstants.Padding.padding10)
            }
            .background(Color.white)
            .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.Padding.padding8)
                        .stroke(
                            validateEmpty && showValidationError && text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                                ? Color.red
                                : .black,
                            lineWidth: 1
                        )
                )
        }
    }
    
    private func makePhoneInputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        validateEmpty: Bool = false,
        showValidationError: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding16) {
            Text(title)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            PhoneFieldView(
                placeholder: placeholder,
                countryCode: "375",
                title: nil,
                keyboardType: .phonePad,
                text: text
            )
            .padding(AppConstants.Padding.padding10)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Padding.padding8)
                    .stroke(
                        validateEmpty && showValidationError && PhoneMask.digits(from: text.wrappedValue).isEmpty
                            ? Color.red
                            : .black,
                        lineWidth: 1
                    )
            )
        }
    }
    
    private var makeDetaPickerSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding8) {
            Text(Constants.Texts.detaPickerTitle)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
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
        VStack(spacing: AppConstants.Padding.padding12) {
            Text(Constants.Texts.confirmTitle)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            HStack(spacing: AppConstants.Padding.padding16) {
                WhiteOrBlackButton(
                    title: Constants.Texts.cancel,
                    backgroundColor: AppConstants.Colors.blackOpacity90,
                    foregroundColor: .white,
                    action: {
                        viewModel.cancelOrder()
                    }
                )
                
                WhiteOrBlackButton(
                    title: Constants.Texts.confirm,
                    backgroundColor: AppConstants.Colors.blackOpacity90,
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
    
    struct LocaleSettings {
        static let russian = Locale(identifier: "ru_RU")
    }
}
