//
//  CatalogViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import Foundation
import SwiftUI
import Combine


class CatalogViewModel: ObservableObject {
    @Published var sushiSets: [SushiSet] = []
    @Published var sushi: [Sushi] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let database: YandexCatalogServiceProtocol
    private let storage: any OrderDataStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        database: YandexCatalogServiceProtocol = YandexCatalogService.shared,
        storage: any OrderDataStoreProtocol
    ) {
        self.storage = storage
        self.database = database
        
        storage.objectWillChange
            .receive(on: RunLoop.main)
            .sink { [weak self] _ in
                self?.objectWillChange.send()
            }
            .store(in: &cancellables)
        
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
        storage.addPosition(position: position)
    }
}
