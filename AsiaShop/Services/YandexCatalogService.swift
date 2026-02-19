//
//  YandexCatalogService.swift
//  AsiaShop
//
//  Загрузка каталога (сеты, суши) из HTTP API Yandex Cloud вместо Firestore.
//

import Foundation

/// Сервис каталога из Yandex Cloud Functions (читает из YDB).
/// Реализует только getSets / getSushi / getSushiAndSets; остальные методы не поддерживаются.
final class YandexCatalogService: DatabaseServiceProtocol {

    static let shared = YandexCatalogService()

    /// URL вашей Cloud Function (каталог). Например: https://xxx.apigw.yandexcloud.net/xxx
    var baseURL: String = ""

    private let session: URLSession = {
        let c = URLSessionConfiguration.default
        c.timeoutIntervalForRequest = 15
        return URLSession(configuration: c)
    }()

    private init() {}

    func getProducts(completion: @escaping (Result<[Product], Error>) -> ()) {
        completion(.failure(NotSupportedError()))
    }

    func getSushi(completion: @escaping (Result<[Sushi], Error>) -> ()) {
        // Пока суши не перенесены в YDB — возвращаем пустой массив
        completion(.success([]))
    }

    func getSets(completion: @escaping (Result<[SushiSet], Error>) -> ()) {
        // Временный вариант: статический список сетов без HTTP.
        let sets: [SushiSet] = [
            SushiSet(
                id: "1",
                imageURL: "asami",
                title: "Асами",
                description: "Сочный лосось, кремовый сыр, хрустящие огурец и снежный краб. Идеальный баланс в каждом кусочке. Попробуй яркое настроение!",
                price: 99.9,
                composition: "Лосось, сыр, огурец, снежный краб, тобико.",
                nutrition: Nutrition(
                    weight: "930г",
                    callories: "1200ккал",
                    protein: nil,
                    fats: nil
                )
            )
        ]
        DispatchQueue.main.async {
            completion(.success(sets))
        }
    }

    func getSushiAndSets(completion: @escaping (Result<(sushi: [Sushi], sets: [SushiSet]), Error>) -> ()) {
        getSets { result in
            switch result {
            case .success(let sets):
                completion(.success((sushi: [], sets: sets)))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

private struct NotSupportedError: LocalizedError {
    var errorDescription: String? { "Метод не поддерживается в YandexCatalogService" }
}
