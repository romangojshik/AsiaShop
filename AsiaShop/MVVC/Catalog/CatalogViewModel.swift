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
    @Published var rollSets: [RollSet] = []
    @Published var rolls: [Roll] = []
    @Published var isLoading: Bool = false
    
    // MARK: - Private Properties
    
    private let catalogService: YandexCatalogServiceProtocol
    private let storage: any OrderDataStoreProtocol
    private var cancellables = Set<AnyCancellable>()
    
    init(
        database: YandexCatalogServiceProtocol = YandexCatalogService.shared,
        storage: any OrderDataStoreProtocol
    ) {
        self.storage = storage
        self.catalogService = database
        
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
        
        catalogService.loadCatalog { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let (rolls, sets)):
                self.rolls = rolls.sorted { $0.title.lowercased() < $1.title.lowercased() }
                
                self.rollSets = sets.sorted {
                    $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending
                }
            case .failure:
                self.rolls = []
                self.rollSets = []
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
