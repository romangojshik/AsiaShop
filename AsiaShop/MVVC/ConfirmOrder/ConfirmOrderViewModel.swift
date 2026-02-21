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
    @Published var showPhoneValidationError: Bool = false
    @Published var showNameValidationError: Bool = false
    
    private let positions: [Position]
    private let onOrderCreated: (String) -> Void
    private let onCancel: () -> Void
    private let clearBasket: () -> Void
    
    init(
        totalCost: Double,
        positions: [Position],
        onOrderCreated: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
        clearBasket: @escaping () -> Void
    ) {
        self.totalCost = totalCost
        self.positions = positions
        self.onOrderCreated = onOrderCreated
        self.onCancel = onCancel
        self.clearBasket = clearBasket
    }
    
    func confirmOrder() {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        showNameValidationError = trimmedName.isEmpty
        showPhoneValidationError = trimmedPhone.isEmpty
        guard !trimmedName.isEmpty else { return }
        guard !trimmedPhone.isEmpty else { return }
        createOrder(userName: trimmedName, userPhone: trimmedPhone)
    }
    
    func createOrder(userName: String, userPhone: String) {
        let order = Order(
            userName: userName,
            numberPhone: userPhone,
            positions: positions,
            status: .new,
            createdAt: Date(),
            readyBy: readyBy
        )
        
        let completion: (Result<Order, Error>) -> Void = { [weak self] result in
            switch result {
            case .success(let order):
                print("Заказ создан: \(order.cost)")
                self?.clearBasket()
                self?.onOrderCreated(userPhone)
            case .failure(let error):
                print("Ошибка: \(error.localizedDescription)")
            }
        }
        
        if YandexOrderService.shared.isConfigured {
            YandexOrderService.shared.submitOrder(order, completion: completion)
        } else {
            DatabaseService.shared.setOrder(order: order, completion: completion)
        }
    }
    
    func cancelOrder() {
        onCancel()
    }
}
