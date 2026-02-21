//
//  YandexCatalogService.swift
//  AsiaShop
//
//  Загрузка каталога (сеты, суши) из HTTP API Yandex Cloud вместо Firestore.
//

import Foundation

/// Сервис каталога из Yandex Cloud Functions (читает из YDB).
/// Реализует getSets и getSushi (суши пока пусто).
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
                let decoded = try JSONDecoder().decode(CatalogAPIResponse.self, from: data)
                if decoded.sets.isEmpty {
                    print("[YandexCatalog] API вернул пустой список")
                }
                DispatchQueue.main.async { completion(.success(decoded.sets)) }
            } catch {
                print("[YandexCatalog] Ошибка декодирования: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

private struct NotSupportedError: LocalizedError {
    var errorDescription: String? { "Метод не поддерживается в YandexCatalogService" }
}

// MARK: - Ответ API каталога (Yandex Cloud)

private struct CatalogAPIResponse: Decodable {
    let sets: [SushiSet]
}
