//
//  OrderAcceptedViewModel.swift
//  AsiaShop
//
//  Created by Cursor on 11/02/26.
//

import Foundation

protocol OrderAcceptedViewModelProtocol: ObservableObject {
    var titleText: String { get }
    var descriptionText: String { get }
    var phoneNumber: String { get }
    func didTapOk()
}

final class OrderAcceptedViewModel: OrderAcceptedViewModelProtocol {
    let titleText: String
    let descriptionText: String
    let phoneNumber: String
    
    private let onOk: () -> Void
    
    init(
        titleText: String = "Ваш заказ принят",
        descriptionText: String = "Ваш заказ принят, ожидайте — с вами свяжутся по номеру телефона.",
        phoneNumber: String,
        onOk: @escaping () -> Void
    ) {
        self.titleText = titleText
        self.descriptionText = descriptionText
        self.phoneNumber = phoneNumber
        self.onOk = onOk
    }
    
    func didTapOk() {
        onOk()
    }
}

