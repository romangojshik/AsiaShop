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
    
    private let database: YandexCatalogServiceProtocol
    private let storage: OrderDataStorage

    init(
        database: YandexCatalogServiceProtocol = YandexCatalogService.shared,
        storage: OrderDataStorage = .shared
    ) {
        self.database = database
        self.storage = storage
        loadProducts()
    }
    
    func loadProducts() {
        isLoading = true

        database.loadCatalog { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (sushi, sets)):
                self.sushi = sushi
                self.sushiSets = sets
            case .failure:
                self.sushi = []
                self.sushiSets = []
            }
            self.isLoading = false
        }
    }
    
    func addToBasket(product: Product) {
        let position = Position(
            id: UUID().uuidString,
            product: product,
            count: 1
        )
        storage.addPosition(position)
    }
}
