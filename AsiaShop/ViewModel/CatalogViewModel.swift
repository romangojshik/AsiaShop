//
//  CatalogViewModel.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import Foundation

class CatalogViewModel: ObservableObject {
    static let shared = CatalogViewModel()
    
    var popularProducts = [
        Product(
            id: "1",
            title: "Тару",
            imageURL: "String",
            price: 16.5,
            description: "Ролл Тару — идеальное сочетание сливочного сыра, нежного лосося и тунца"
        ),
        Product(
            id: "2",
            title: "Тунец",
            imageURL: "String",
            price: 15.5,
            description: "Ролл Тару — идеальное сочетание сливочного сыра, нежного лосося и тунца"
        ),
        Product(
            id: "3",
            title: "Нори",
            imageURL: "String",
            price: 17.5,
            description: "Наши жареные роллы — это искусство, созданное любовью"
        ),
        Product(
            id: "4",
            title: "Жареные",
            imageURL: "String",
            price: 19,
            description: "Наши жареные роллы — это искусство, созданное любовью"
        )
    ]
    
    var sushi = [
        Product(
            id: "1",
            title: "Тару",
            imageURL: "String",
            price: 16.5,
            description: "Ролл Тару — идеальное сочетание сливочного сыра, нежного лосося и тунца"
        ),
        Product(
            id: "2",
            title: "Тунец",
            imageURL: "String",
            price: 15.5,
            description: "Ролл Тару — идеальное сочетание сливочного сыра, нежного лосося и тунца"
        ),
        Product(
            id: "3",
            title: "Нори",
            imageURL: "String",
            price: 17.5,
            description: "Наши жареные роллы — это искусство, созданное любовью"
        ),
        Product(
            id: "4",
            title: "Жареные",
            imageURL: "String",
            price: 19,
            description: "Наши жареные роллы — это искусство, созданное любовью"
        )
    ]
    
    
    
}
