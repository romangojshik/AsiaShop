//
//  CatalogViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import Foundation
import SwiftUI

protocol CatalogViewModelProtocol: ObservableObject {
    var sushiSets: [SushiSet] { get }
    var sushi: [Sushi] { get }
    var isLoading: Bool { get }

    func loadProducts()
    func addToBasket(product: Product)
}

class CatalogViewModel: CatalogViewModelProtocol {
    
    @Published var sushiSets: [SushiSet] = []
    @Published var sushi: [Sushi] = []
    @Published var isLoading: Bool = false
    
    private let database: DatabaseServiceProtocol
    private let basket: any BasketViewModelProtocol

    init(
        database: DatabaseServiceProtocol = DatabaseService.shared,
        basket: any BasketViewModelProtocol
    ) {
        self.database = database
        self.basket = basket
        loadProducts()
    }
    
    func loadProducts() {
        isLoading = true
        
        database.getSets { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let sets):
                    self.sushiSets = sets
                case .failure(let error):
                    print("Ошибка загрузки сетов: \(error.localizedDescription)")
                    self.sushiSets = []
                }
                
                self.isLoading = false
            }
        }
        
        database.getSushi { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let sushi):
                    self.sushi = sushi
                case .failure(let error):
                    print("Ошибка загрузки суш: \(error.localizedDescription)")
                    self.sushi = []
                }
            }
        }
    }
    
    func addToBasket(product: Product) {
        let position = Position(
            id: UUID().uuidString,
            product: product,
            count: 1
        )
        basket.addPosition(position)
    }
}
