//
//  OrderAcceptedViewModel.swift
//  AsiaShop
//
//  Created by Cursor on 11/02/26.
//

import Foundation

protocol OrderAcceptedViewModelProtocol: ObservableObject {
    var userPhoneNumber: String { get }
    
    func didTapOk()
}

final class OrderAcceptedViewModel: OrderAcceptedViewModelProtocol {
    let userPhoneNumber: String
    
    private let onOk: () -> Void
    
    init(
        userPhoneNumber: String,
        onOk: @escaping () -> Void
    ) {
        self.userPhoneNumber = userPhoneNumber
        self.onOk = onOk
    }
    
    func didTapOk() {
        onOk()
    }
}

