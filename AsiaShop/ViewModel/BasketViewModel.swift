//
//  BasketViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation

class BasketViewModel: ObservableObject {
    
    static let shared = BasketViewModel()
    
    private init() {
        
    }
    
    @Published var positions = [Position]()
    
    var cost: Double {
        var sum = 0.0
        
        for pos in positions {
            sum += pos.cost
        }
        
        return sum
    }
    
    func addPosition(position: Position) {
        positions.append(position)
    }
}
