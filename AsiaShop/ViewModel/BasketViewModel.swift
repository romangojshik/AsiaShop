//
//  BasketViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/23/23.
//

import Foundation

class BasketViewModel: ObservableObject {
    
    @Published var positions = [Position]()
    
    func ddPosition(position: Position) {
        positions.append(position)
    }
}
