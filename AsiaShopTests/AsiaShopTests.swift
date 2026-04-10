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

/// Resolves `AsiaShopTests/Fixtures/<name>.<ext>` in the test bundle. Nuke loads `file://` like remote URLs.
private final class FixtureBundleToken {}

private func fixtureImageURL(fileName: String, fileExtension: String) -> String {
    let bundle = Bundle(for: FixtureBundleToken.self)
    guard let url = bundle.url(forResource: fileName, withExtension: fileExtension) else {
        preconditionFailure("Add \(fileName).\(fileExtension) to AsiaShopTests/Fixtures (test target resources).")
    }
    return url.absoluteString
}

private var isSnapshotRecording: Bool {
    ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
}

@MainActor
struct CatalogSnapshotTests {
    @Test func catalog_loaded_state() async {
        let storage = OrderDataStorage()

        let database = MockYandexCatalogService(
            rolls: [
                Roll(
                    id: "roll_1",
                    imageURL: fixtureImageURL(fileName: "nori", fileExtension: "jpeg"),
                    title: "Калифорния с Лососем",
                    description: "Лосось, огурец, сыр, рис",
                    price: 17,
                    composition: "Лосось, огурец, сыр, рис",
                    nutrition: Nutrition(weight: "34", callories: nil, proteins: nil, fats: nil)
                ),
                Roll(
                    id: "roll_2",
                    imageURL: fixtureImageURL(fileName: "Taru", fileExtension: "png"),
                    title: "Тару",
                    description: "Рис, майонез, креветка, огурец",
                    price: 20,
                    composition: "Рис, майонез, креветка, огурец",
                    nutrition: Nutrition(weight: "56", callories: nil, proteins: nil, fats: nil)
                ),
                Roll(
                    id: "roll_3",
                    imageURL: fixtureImageURL(fileName: "fried", fileExtension: "png"),
                    title: "Жаренные",
                    description: "Рис для суши, лист нори, сливочный сыр, лосось, панировка",
                    price: 16,
                    composition: "Рис для суши, лист нори, сливочный сыр, лосось, панировка",
                    nutrition: Nutrition(weight: "44", callories: nil, proteins: nil, fats: nil)
                )
            ],
            rollSets: [
                RollSet(
                    id: "set_1",
                    imageURL: fixtureImageURL(fileName: "set_gejsha", fileExtension: "jpg"),
                    title: "Гейша",
                    description: "Касуми, Красный дракон, Калифорния",
                    price: 62,
                    composition: nil,
                    nutrition: Nutrition(weight: "690", callories: "970", proteins: nil, fats: nil)
                ),
                RollSet(
                    id: "set_2",
                    imageURL: fixtureImageURL(fileName: "set_osaka", fileExtension: "jpg"),
                    title: "Осака",
                    description: "Коивака, Мару, Тару, Кацу",
                    price: 70,
                    composition: nil,
                    nutrition: Nutrition(weight: "433", callories: nil, proteins: "56", fats: "32")
                ),
                RollSet(
                    id: "set_3",
                    imageURL: fixtureImageURL(fileName: "set_imperatorskij", fileExtension: "jpg"),
                    title: "Императорский",
                    description: "Акацуки, Магуро, Каясо, Микан, Нью-Иорк, Хотатэгай, Широгома, Амаэби",
                    price: 140,
                    composition: nil,
                    nutrition: Nutrition(weight: "1333", callories: nil, proteins: nil, fats: nil)
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
        host.view.backgroundColor = .systemBackground
        host.view.setNeedsLayout()
        host.view.layoutIfNeeded()

        await Task.yield()

        assertSnapshot(
            of: host,
            as: .image(precision: 0.99, perceptualPrecision: 0.98),
            record: isSnapshotRecording
        )
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
