//
//  CatalogFixtures.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 14.04.26.
//

import Foundation
@testable import AsiaShop

enum CatalogFixtures {
    static func rolls() -> [Roll] {
        [
            Roll(
                id: "roll_1",
                imageURL: "roll_raduga",
                title: "Радуга",
                description: "Рис, нори, креветка, огурец, лосось, тунец, сыр творожный, икра лососевая.",
                price: 17,
                composition: "Лосось, огурец, сыр, рис",
                nutrition: Nutrition(weight: "34", caloriesPer100g: nil, proteins: nil, fats: nil)
            ),
            Roll(
                id: "roll_2",
                imageURL: "roll_syakemaki",
                title: "Сяке маки",
                description: "Рис, майонез, креветка, огурец",
                price: 20,
                composition: "Рис, нори, лосось, огурец.",
                nutrition: Nutrition(weight: "56", caloriesPer100g: nil, proteins: nil, fats: nil)
            ),
            Roll(
                id: "roll_3",
                imageURL: "roll_syakeavokado",
                title: "Сяке авокадо",
                description: "Рис для суши, лист нори, сливочный сыр, лосось, панировка",
                price: 16,
                composition: "Рис, нори, лосось, авокадо.",
                nutrition: Nutrition(weight: "44", caloriesPer100g: nil, proteins: nil, fats: nil)
            )
        ]
    }

    static func sets() -> [RollSet] {
        [
            RollSet(
                id: "set_1",
                imageURL: "set_gejsha",
                title: "Гейша",
                description: "Касуми, Красный дракон, Калифорния",
                price: 62,
                composition: nil,
                nutrition: Nutrition(weight: "690", caloriesPer100g: "970", proteins: nil, fats: nil)
            ),
            RollSet(
                id: "set_2",
                imageURL: "set_osaka",
                title: "Осака",
                description: "Коивака, Мару, Тару, Кацу",
                price: 70,
                composition: nil,
                nutrition: Nutrition(weight: "433", caloriesPer100g: nil, proteins: "56", fats: "32")
            ),
            RollSet(
                id: "set_3",
                imageURL: "set_imperatorskij",
                title: "Императорский",
                description: "Акацуки, Магуро, Каясо, Микан, Нью-Иорк, Хотатэгай, Широгома, Амаэби",
                price: 140,
                composition: nil,
                nutrition: Nutrition(weight: "1333", caloriesPer100g: nil, proteins: nil, fats: nil)
            )
        ]
    }
}
