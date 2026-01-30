//
//  BasketViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation

protocol BasketViewModelProtocol: ObservableObject {
    var positions: [Position] { get set }
    var cost: Double { get }
    func addPosition(_ position: Position)
    func isProductInBasket(productId: String) -> Bool
    func getProductCount(productId: String) -> Int
    func increaseCount(positionId: String)
    func decreaseCount(positionId: String)
    func removePosition(positionId: String)
}

class BasketViewModel: BasketViewModelProtocol {
    @Published var positions = [Position]()
    
    init() {}
    
    //var cost: Double { positions.reduce(0) { $0 + $1.cost } }
    var cost: Double {
        var sum = 0.0
        for pos in positions {
            sum += pos.cost
        }
        return sum
    }
    
    func addPosition(_ position: Position) {
        positions.append(position)
    }
    
    func isProductInBasket(productId: String) -> Bool {
        return positions.contains { $0.product.id == productId }
    }
    
    func getProductCount(productId: String) -> Int {
        return positions.first(where: { $0.product.id == productId })?.count ?? 0
    }
    
    func increaseCount(positionId: String) {
        if let index = positions.firstIndex(where: { $0.id == positionId }) {
            positions[index].count += 1
        }
    }
    
    func decreaseCount(positionId: String) {
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
}
