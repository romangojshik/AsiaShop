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
    var isFormValid: Bool { get }
    
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
    private let getTotalCost: () -> Double
    private let getExtras: () -> [String: Int]
    private let onOrderCreated: (String) -> Void
    private let onCancel: () -> Void
    private let clearBasket: () -> Void
    
    init(
        totalCost: Double,
        positions: [Position],
        getTotalCost: (() -> Double)? = nil,
        getExtras: (() -> [String: Int])? = nil,
        onOrderCreated: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
        clearBasket: @escaping () -> Void
    ) {
        self.totalCost = totalCost
        self.positions = positions
        self.getTotalCost = getTotalCost ?? { totalCost }
        self.getExtras = getExtras ?? { [:] }
        self.onOrderCreated = onOrderCreated
        self.onCancel = onCancel
        self.clearBasket = clearBasket
    }
    
    /// Кнопка «Подтвердить» активна только когда заполнены имя и телефон.
    var isFormValid: Bool {
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneDigits = PhoneMask.digits(from: phone)
        return !name.isEmpty && !phoneDigits.isEmpty
    }
    
    func confirmOrder() {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        showNameValidationError = trimmedName.isEmpty
        showPhoneValidationError = trimmedPhone.isEmpty
        
        guard
            !trimmedName.isEmpty,
            !trimmedPhone.isEmpty
        else { return }
        
        createOrder(userName: trimmedName, userPhone: trimmedPhone)
    }
    
    func createOrder(userName: String, userPhone: String) {
        let order = Order(
            userName: userName,
            numberPhone: userPhone,
            positions: positions,
            createdAt: Date(),
            readyBy: readyBy,
            total: getTotalCost(),
            extras: getExtras()
        )

        Task { @MainActor in
            do {
                _ = try await YandexOrderService.shared.submitOrder(order)
                clearBasket()
                onOrderCreated(userPhone)
            } catch {
                print("Ошибка: \(error.localizedDescription)")
            }
        }
    }
    
    func cancelOrder() {
        onCancel()
    }
}
