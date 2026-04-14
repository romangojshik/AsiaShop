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

private var isSnapshotRecording: Bool {
    ProcessInfo.processInfo.environment["RECORD_SNAPSHOTS"] == "1"
}

@MainActor
struct CatalogSnapshotTests {
    @Test func catalog_loaded_state() async {
        setenv("SNAPSHOT_USE_ASSETS", "1", 1)
        defer { unsetenv("SNAPSHOT_USE_ASSETS") }
        let storage = OrderDataStorage()

        let database = MockYandexCatalogService(
            rolls: CatalogFixtures.rolls(),
            rollSets: CatalogFixtures.sets()
        )

        let viewModel = CatalogViewModel(database: database, storage: storage)

        // Wait until view model finishes loading (so shimmer won't be shown).
        let deadline = Date().addingTimeInterval(2.0)
        while (viewModel.isLoading || viewModel.rolls.isEmpty || viewModel.rollSets.isEmpty) && Date() < deadline {
            await Task.yield()
        }
        await Task.yield()

        let view = CatalogContentView(viewModel: viewModel).environmentObject(storage)

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
