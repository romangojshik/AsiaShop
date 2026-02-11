//
//  ConfirmOrderViewModel.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import Foundation

protocol ConfirmOrderViewModelProtocol: ObservableObject {
    var totalCost: Double { get }
    var userName: String { get set }
    var phone: String { get set }
    var readyBy: Date? { get set }
    func confirmOrder()
    func cancelOrder()
}

class ConfirmOrderViewModel: ConfirmOrderViewModelProtocol {
    @Published var totalCost: Double
    @Published var userName: String = ""
    @Published var phone: String = ""
    @Published var readyBy: Date?
    
    private let onConfirm: (String, String, Date?) -> Void
    private let onCancel: () -> Void
    
    init(
        totalCost: Double,
        onConfirm: @escaping (String, String, Date?) -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.totalCost = totalCost
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    func confirmOrder() {
        // Не даём оформить заказ без номера телефона
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedPhone.isEmpty else {
            return
        }
        
        onConfirm(userName, phone, readyBy)
    }
    
    func cancelOrder() {
        onCancel()
    }
}
