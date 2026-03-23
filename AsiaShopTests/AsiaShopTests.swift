//
//  AsiaShopTests.swift
//  AsiaShopTests
//
//  Created by Roman Gojshik on 10.02.26.
//

import Testing
import SnapshotTesting
import SwiftUI
import UIKit

@testable import AsiaShop

@MainActor
struct CatalogSnapshotTests {
    @Test func catalog_loaded_state() async {
        let storage = OrderDataStorage()

        let database = MockYandexCatalogService(
            rolls: [
                Roll(
                    id: "roll_1",
                    imageURL: "",
                    title: "Калифорния с Лососем",
                    description: "Лосось, огурец, сыр, рис",
                    price: 17,
                    composition: "Лосось, огурец, сыр, рис",
                    nutrition: Nutrition(weight: "34", callories: nil, protein: nil, fats: nil)
                ),
                Roll(
                    id: "roll_2",
                    imageURL: "",
                    title: "Тару",
                    description: "Рис, майонез, креветка, огурец",
                    price: 20,
                    composition: "Рис, майонез, креветка, огурец",
                    nutrition: Nutrition(weight: "56", callories: nil, protein: nil, fats: nil)
                ),
                Roll(
                    id: "roll_3",
                    imageURL: "",
                    title: "Жаренные",
                    description: "Рис для суши, лист нори, сливочный сыр, лосось, панировка",
                    price: 16,
                    composition: "Рис для суши, лист нори, сливочный сыр, лосось, панировка",
                    nutrition: Nutrition(weight: "44", callories: nil, protein: nil, fats: nil)
                )
            ],
            rollSets: [
                RollSet(
                    id: "set_1",
                    imageURL: "",
                    title: "Аками",
                    description: "Набор",
                    price: 99,
                    composition: nil,
                    nutrition: Nutrition(weight: "1555", callories: nil, protein: nil, fats: nil)
                ),
                RollSet(
                    id: "set_2",
                    imageURL: "",
                    title: "Баунти",
                    description: "Набор",
                    price: 98,
                    composition: nil,
                    nutrition: Nutrition(weight: "433", callories: nil, protein: nil, fats: nil)
                ),
                RollSet(
                    id: "set_3",
                    imageURL: "",
                    title: "Темари",
                    description: "Набор",
                    price: 112,
                    composition: nil,
                    nutrition: Nutrition(weight: "1333", callories: nil, protein: nil, fats: nil)
                )
            ]
        )

        let viewModel = CatalogViewModel(database: database, storage: storage)

        // Wait until view model finishes loading (so shimmer won't be shown).
        let deadline = Date().addingTimeInterval(2.0)
        while (viewModel.isLoading || viewModel.rolls.isEmpty || viewModel.rollSets.isEmpty) && Date() < deadline {
            await Task.yield()
        }
        await Task.yield()

        let view = CatalogContentView(viewModel: viewModel)
            .environmentObject(storage)

        let host = UIHostingController(rootView: view)
        host.view.frame = CGRect(x: 0, y: 0, width: 390, height: 844) // iPhone-like size

        assertSnapshot(of: host, as: .image)
    }
}

private final class MockYandexCatalogService: YandexCatalogServiceProtocol {
    let rolls: [Roll]
    let rollSets: [RollSet]

    init(rolls: [Roll], rollSets: [RollSet]) {
        self.rolls = rolls
        self.rollSets = rollSets
    }

    func loadCatalog(
        completion: @escaping (Result<([Roll], [RollSet]), Error>) -> Void
    ) {
        completion(.success((self.rolls, self.rollSets)))
    }
}
