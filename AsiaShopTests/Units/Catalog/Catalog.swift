//
//  Catalog.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 14.04.26.
//

import Testing
import Mockingbird
@testable import AsiaShop

//@MainActor
//struct CatalogViewModelTests {
//    
//    @Test
//    func loadProducts_callsService() async {
//        let service = mock(YandexCatalogServiceProtocol.self)
//        let storage = OrderDataStorage()
//        
////        given(service.loadCatalog(completion: any())).will { completion in
////            completion(.success(([], [])))
////        }
//        
//        given(service.loadCatalog(completion: any())).will { (completion: @escaping (Result<([Roll], [RollSet]), Error>) -> Void) in
//            completion(.success(([], [])))
//        }
//        
//        let sut = CatalogViewModel(database: service, storage: storage)
//        
//        sut.loadProducts()
//        await Task.yield() // дать async completion отработать
//        verify(service.loadCatalog(completion: any())).wasCalled()
//    }
//}
