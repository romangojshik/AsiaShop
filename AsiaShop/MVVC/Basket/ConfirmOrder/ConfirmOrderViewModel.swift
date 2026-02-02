//
//  ConfirmOrderViewModel.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import Foundation

protocol ConfirmOrderViewModelProtocol: ObservableObject {
    var totalCost: Double { get }
    func confirmOrder()
    func cancelOrder()
}

class ConfirmOrderViewModel: ConfirmOrderViewModelProtocol {
    @Published var totalCost: Double
    
    private let onConfirm: () -> Void
    private let onCancel: () -> Void
    
    init(
        totalCost: Double,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.totalCost = totalCost
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    func confirmOrder() {
        onConfirm()
    }
    
    func cancelOrder() {
        onCancel()
    }
}
