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

    /// URL API Gateway (каталог). От поддержки Yandex Cloud.
    var baseURL: String = "https://d5di93907ln32br63enu.emzafcgx.apigw.yandexcloud.net"

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
        guard !baseURL.isEmpty, let url = URL(string: baseURL.hasSuffix("/") ? baseURL : baseURL + "/") else {
            DispatchQueue.main.async { completion(.failure(URLError(.badURL))) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[YandexCatalog] Ошибка: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                print("[YandexCatalog] Пустой ответ")
                DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
                return
            }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("[YandexCatalog] HTTP \(http.statusCode): \(body.prefix(150))")
                let err = NSError(domain: "YandexCatalog", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(CatalogResponse.self, from: data)
                let sets = decoded.sets.map { item in
                    SushiSet(
                        id: item.id,
                        imageURL: item.imageURL,
                        title: item.title,
                        description: item.description,
                        price: item.price,
                        composition: item.composition,
                        nutrition: item.nutrition.map { Nutrition(
                            weight: $0.weight,
                            callories: $0.callories,
                            protein: $0.protein,
                            fats: $0.fats
                        ) }
                    )
                }
                if sets.isEmpty {
                    print("[YandexCatalog] API вернул пустой список")
                }
                DispatchQueue.main.async { completion(.success(sets)) }
            } catch {
                print("[YandexCatalog] Ошибка декодирования: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
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

// MARK: - Ответ API каталога (Cloud Function)

private struct CatalogResponse: Decodable {
    let sets: [CatalogSetItem]
}

private struct CatalogSetItem: Decodable {
    let id: String
    let title: String
    let imageURL: String
    let description: String
    let price: Double
    let composition: String?
    let nutrition: CatalogNutrition?
}

private struct CatalogNutrition: Decodable {
    let weight: String?
    let callories: String?
    let protein: String?
    let fats: String?
}
