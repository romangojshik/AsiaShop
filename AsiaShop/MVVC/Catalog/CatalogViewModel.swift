//
//  CatalogViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import Foundation
import SwiftUI

class CatalogViewModel: ObservableObject {
    
    @Published var sushiSets: [SushiSet] = []
    @Published var popularProducts: [Product] = []
    @Published var allProducts: [Product] = []
    @Published var isLoading: Bool = false
    
    private let database: DatabaseServiceProtocol

    init(database: DatabaseServiceProtocol = DatabaseService.shared) {
        self.database = database
        loadProducts()
    }
    
    func loadProducts() {
        isLoading = true
        
        // Загружаем сеты для recommendedProducts
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
        
        // Загружаем продукты для allProducts
        database.getProducts { [weak self] result in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                switch result {
                case .success(let products):
                    self.allProducts = products
                    self.popularProducts = []
                case .failure(let error):
                    print("Ошибка загрузки продуктов: \(error.localizedDescription)")
                    self.allProducts = []
                    self.popularProducts = []
                }
            }
        }
    }
}
