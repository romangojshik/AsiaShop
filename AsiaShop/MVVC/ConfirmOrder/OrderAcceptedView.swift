//
//  OrderAcceptedView.swift
//  AsiaShop
//
//  Created by Cursor on 11/02/26.
//

import SwiftUI

struct OrderAcceptedView: View {
    @StateObject var viewModel: OrderAcceptedViewModel
    
    var body: some View {
        VStack(spacing: 24) {
            Text(Constants.Texts.title)
                .font(Constants.Fonts.titleFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
                .multilineTextAlignment(.center)
            
            Text(Constants.Texts.description)
                .font(Constants.Fonts.titleDescriptionFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            WhiteOrBlackButton(
                title: Constants.Texts.okButton,
                backgroundColor: Color(white: 0.15),
                foregroundColor: .white
            ) {
                viewModel.didTapOk()
            }
            .padding(.horizontal)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - Constants

private struct Constants {
    struct Images {}
    
    struct Texts {
        static let title = "Ваш заказ принят"
        static let description = "Ваш заказ принят, ожидайте — с вами свяжутся по номеру телефона."
        static let okButton = "Ок"
    }
    
    struct Fonts {
        static let titleFont = SwiftUI.Font.system(size: 20, weight: .bold)
        static let titleDescriptionFont = SwiftUI.Font.system(size: 14, weight: .semibold)
        static let titleTextFont = SwiftUI.Font.system(size: 16, weight: .medium)
    }
    
    struct LocaleSettings {
        static let russian = Locale(identifier: "ru_RU")
    }
}

// MARK: - Preview

#Preview {
    OrderAcceptedView(
        viewModel: OrderAcceptedViewModel(
            userPhoneNumber: "",
            onOk: {}
        )
    )
}

