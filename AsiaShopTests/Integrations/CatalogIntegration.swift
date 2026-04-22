//
//  CatalogIntegration.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 20.04.26.
//

@testable import AsiaShop
import Mockingbird
import XCTest


final class CatalogIntegration: XCTestCase {
//    let catalogService = mock(YandexCatalogServiceProtocol.self)
//    let storage = mock(OrderDataStoreProtocol.self)
//    
//    let viewModel = CatalogViewModel(database: database, storage: storage)
    
    private var storage: OrderDataStorage! // реальная реализация (не mock)
    private var database: StubCatalogService!
    private var viewModel: CatalogViewModel!
    
    override func setUpWithError() throws {
        storage = OrderDataStorage()
        //Stub - это тестовый “подставной” объект, который возвращает заранее заданные данные, чтобы тест был предсказуемым.
        database = StubCatalogService(result: .success(([],[])))
        viewModel = CatalogViewModel(database: database, storage: storage)
    }
    
    func test_addToBasket_sameProduct_doesNotCreateDuplicatePosition() throws {
        //XCTUnwrap - это удобный способ в XCTest безопасно достать значение из optional в тесте.
        let product = try XCTUnwrap(CatalogFixtures.rolls().first?.toProduct())
        
        viewModel.addToBasket(product: product)
        viewModel.addToBasket(product: product)
        
        //Проверяем, что в корзине появилась ровно одна позиция.
        XCTAssertEqual(storage.positions.count, 1)
        //Проверяем, что добавился именно нужный товар, а не какой-то другой.
        XCTAssertEqual(storage.positions.first?.product.id, product.id)
        // Проверяем стартовое количество для новой позиции — 1 штука.
        XCTAssertEqual(storage.positions.first?.count, 1)
    }
    
}

private struct StubCatalogService: YandexCatalogServiceProtocol {
    let result: Result<([Roll], [RollSet]), Error>
    
    func loadCatalog(completion: @escaping (Result<([Roll], [RollSet]), Error>) -> Void) {
        completion(result)
    }
}
