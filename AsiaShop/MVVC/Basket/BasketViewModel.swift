//
//  BasketViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation
import Combine

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
    private let storage: OrderDataStorage
    private var cancellables = Set<AnyCancellable>()
    
    var positions: [Position] {
        get { storage.positions }
        set { storage.positions = newValue }
    }
    
    var cost: Double {
        storage.cost
    }
    
    init(storage: OrderDataStorage = .shared) {
        self.storage = storage
        storage.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
    }
    
    func addPosition(_ position: Position) {
        storage.addPosition(position)
    }
    
    func isProductInBasket(productId: String) -> Bool {
        storage.isProductInBasket(productId: productId)
    }
    
    func getProductCount(productId: String) -> Int {
        storage.getProductCount(productId: productId)
    }
    
    func increaseCount(positionId: String) {
        storage.increaseCount(positionId: positionId)
    }
    
    func decreaseCount(positionId: String) {
        storage.decreaseCount(positionId: positionId)
    }
    
    /// Для каталога: уменьшить, а при 1 — удалить позицию.
    func decreaseOrRemove(positionId: String) {
        storage.decreaseOrRemove(positionId: positionId)
    }
    
    func removePosition(positionId: String) {
        storage.removePosition(positionId: positionId)
    }
    
    func clearBasket() {
        storage.clearBasket()
    }
}
