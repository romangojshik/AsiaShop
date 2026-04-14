//
//  CatalogXCTest.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 14.04.26.
//

import XCTest
import Mockingbird
@testable import AsiaShop

//@MainActor
//final class CatalogViewModelXCTests: XCTestCase {
//    
//    func test_loadProducts_callsService() async {
//        let service = mock(YandexCatalogServiceProtocol.self)
//        let storage = OrderDataStorage()
//        
//        given(service.loadCatalog(completion: any())).will { (completion: @escaping (Result<([Roll], [RollSet]), Error>) -> Void) in
//            completion(.success(([], [])))
//        }
//        
//        let sut = CatalogViewModel(database: service, storage: storage)
//        sut.loadProducts()
//        
//        await Task.yield() // дать async completion отработать
//        verify(service.loadCatalog(completion: any())).wasCalled()
//    }
//    
//}

@MainActor
final class CatalogViewModelXCTests: XCTestCase {
    
    func test_loadProducts_callsService() async {
        let service = ManualMockYandexCatalogService(
            result: .success(([], []))
        )
        let storage = OrderDataStorage()
        
        _ = CatalogViewModel(database: service, storage: storage)
        
        await Task.yield() // дать async completion отработать
        
        XCTAssertEqual(service.loadCatalogCallCount, 1)
    }
}

private final class ManualMockYandexCatalogService: YandexCatalogServiceProtocol {
    private let result: Result<([Roll], [RollSet]), Error>
    private(set) var loadCatalogCallCount = 0
    
    init(result: Result<([Roll], [RollSet]), Error>) {
        self.result = result
    }
    
    func loadCatalog(
        completion: @escaping (Result<([Roll], [RollSet]), Error>) -> Void
    ) {
        loadCatalogCallCount += 1
        completion(result)
    }
}
