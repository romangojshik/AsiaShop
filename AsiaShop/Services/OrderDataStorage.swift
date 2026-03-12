//
//  OrderDataStorage.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 12/02/26.
//

import Foundation
import Combine

enum ExtraButton: String, CaseIterable {
    case chopsticks = "Палочки"
    case wasabi = "Васаби"
    case ginger = "Имбирь"
    case soySauce = "Соевый соус"
    case nutSauce = "Ореховый соус"
    
    /// Дополнения со степпером (− N +), не чекбоксом.
    static var stepperExtras: [ExtraButton] { [.chopsticks, .wasabi, .ginger, .soySauce, .nutSauce] }
    
    var price: Double {
        switch self {
        case .chopsticks:
            return 0
        case .wasabi, .ginger, .soySauce, .nutSauce:
            return 2
        }
    }
}

final class OrderDataStorage: ObservableObject {
    
    static let shared = OrderDataStorage()
    
    @Published var positions: [Position] = []
    
    @Published var ExtraCountDict: [ExtraButton: Int] = {
        Dictionary(uniqueKeysWithValues: ExtraButton.allCases.map { ($0, 0) })
    }()
    
    /// Стоимость дополнений. Реактивно пересчитывается при изменении addOnCounts.
    var addOnsCost: Double {
        ExtraCountDict.reduce(0) { sum, item in
            sum + Double(item.value) * item.key.price
        }
    }
    
    /// Стоимость позиций (без дополнений).
    var cost: Double {
        positions.reduce(0) { $0 + $1.cost }
    }
    
    /// Общая сумма: позиции + дополнения.
    var totalCost: Double {
        cost + addOnsCost
    }
    
    private init() {}
    
    func addPosition(_ position: Position) {
        positions.append(position)
    }
    
    func isProductInBasket(productId: String) -> Bool {
        positions.contains { $0.product.id == productId }
    }
    
    func getProductCount(productId: String) -> Int {
        positions.first(where: { $0.product.id == productId })?.count ?? 0
    }
    
    func increaseCount(positionId: String) {
        if let index = positions.firstIndex(where: { $0.id == positionId }) {
            positions[index].count += 1
        }
    }
    
    /// Для корзины: уменьшить, но не удалять позицию (минимум 1).
    func decreaseCount(positionId: String) {
        if let index = positions.firstIndex(where: { $0.id == positionId }) {
            if positions[index].count > 1 {
                positions[index].count -= 1
            }
        }
    }
    
    /// Для каталога: уменьшить, а при 1 — удалить позицию.
    func decreaseOrRemove(positionId: String) {
        if let index = positions.firstIndex(where: { $0.id == positionId }) {
            if positions[index].count > 1 {
                positions[index].count -= 1
            } else {
                positions.remove(at: index)
            }
        }
    }
    
    func removePosition(positionId: String) {
        positions.removeAll { $0.id == positionId }
    }
    
    func clearBasket() {
        positions.removeAll()
        ExtraCountDict = Dictionary(uniqueKeysWithValues: ExtraButton.allCases.map { ($0, 0) })
    }
    
    /// Блок дополнение к заказу, стоимость(палочек, соусов)
    
    func extraCount(extra: ExtraButton) -> Int {
        ExtraCountDict[extra] ?? 0
    }
    
    func increaseAddOn(extra: ExtraButton) {
        ExtraCountDict[extra, default: 0] += 1
    }
    
    func decreaseAddOn(extra: ExtraButton) {
        let current = ExtraCountDict[extra] ?? 0
        if current > 0 {
            ExtraCountDict[extra] = current - 1
        }
    }
}
