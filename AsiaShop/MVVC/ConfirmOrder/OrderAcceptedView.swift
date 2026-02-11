//
//  OrderAcceptedView.swift
//  AsiaShop
//
//  Created by Cursor on 11/02/26.
//

import SwiftUI

struct OrderAcceptedView: View {
    @StateObject private var viewModel: OrderAcceptedViewModel
    
    init(viewModel: OrderAcceptedViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack(spacing: 24) {
            Text(Constants.Texts.title)
                .font(.title2)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(Constants.Texts.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            
            WhiteOrBlackButton(
                title: "Ок",
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
    OrderAcceptedView(
        viewModel: OrderAcceptedViewModel(
            userPhoneNumber: "",
            onOk: {}
        )
    )
}

