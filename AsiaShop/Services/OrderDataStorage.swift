//
//  OrderDataStorage.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 12/02/26.
//

import Foundation
import Combine

final class OrderDataStorage: ObservableObject {
    static let shared = OrderDataStorage()
    
    @Published var positions: [Position] = []
    
    var cost: Double {
        positions.reduce(0) { $0 + $1.cost }
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
    }
}
