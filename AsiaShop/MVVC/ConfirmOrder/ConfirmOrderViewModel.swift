//
//  ConfirmOrderViewModel.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import Foundation


class ConfirmOrderViewModel: ObservableObject {
    @Published var totalCost: Double
    @Published var userName: String = ""
    @Published var phone: String = ""
    @Published var readyBy: Date?
    
    private let positions: [Position]
    private let getTotalCost: () -> Double
    private let extras: String
    private let onOrderCreated: (String) -> Void
    private let onCancel: () -> Void
    private let clearBasket: () -> Void
    
    init(
        totalCost: Double,
        positions: [Position],
        getTotalCost: (() -> Double)? = nil,
        extras: String,
        onOrderCreated: @escaping (String) -> Void,
        onCancel: @escaping () -> Void,
        clearBasket: @escaping () -> Void
    ) {
        self.totalCost = totalCost
        self.positions = positions
        self.getTotalCost = getTotalCost ?? { totalCost }
        self.extras = extras
        self.onOrderCreated = onOrderCreated
        self.onCancel = onCancel
        self.clearBasket = clearBasket
    }
    
    /// Кнопка «Подтвердить» активна только когда заполнены имя и телефон.
    var isFormValid: Bool {
        let name = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let phoneDigits = PhoneMask.digits(from: phone)
        // Требуем полностью введённый номер: 9 цифр после +375
        return !name.isEmpty && phoneDigits.count == 9
    }
    
    func confirmOrder() {
        let trimmedName = userName.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPhone = phone.trimmingCharacters(in: .whitespacesAndNewlines)
        
        let phoneDigits = PhoneMask.digits(from: trimmedPhone)
        guard
            !trimmedName.isEmpty,
            phoneDigits.count == 9
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
            extras: extras
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
