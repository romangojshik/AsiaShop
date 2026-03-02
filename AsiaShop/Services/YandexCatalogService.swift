//
//  YandexCatalogService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 12/02/26.
//

import Foundation

// MARK: - YandexCatalogServiceProtocol

protocol YandexCatalogServiceProtocol {
    func loadCatalog(completion: @escaping (Result<([Sushi], [SushiSet]), Error>) -> Void)
}

final class YandexCatalogService {
    
    static let shared = YandexCatalogService()

    private init() {}
    
    // MARK: - Private methods
    
    private func getSushi(completion: @escaping (Result<[Sushi], Error>) -> ()) {
        guard
            !YandexAPIConfig.baseURL.isEmpty,
            let url = URL(string: (YandexAPIConfig.baseURL.hasSuffix("/") ? YandexAPIConfig.baseURL : YandexAPIConfig.baseURL + "/") + "sushi")
        else {
            DispatchQueue.main.async { completion(.failure(URLError(.badURL))) }
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        YandexAPIConfig.session.dataTask(with: request) { data, response, error in
            if let error = error {
                print("[YandexCatalog] Sushi error: \(error.localizedDescription)")
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                print("[YandexCatalog] Sushi: empty response")
                DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
                return
            }
            
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let body = String(data: data, encoding: .utf8) ?? ""
                print("[YandexCatalog] Sushi HTTP \(http.statusCode): \(body.prefix(150))")
                let err = NSError(
                    domain: "YandexCatalogSushi",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"]
                )
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(SushiAPIResponse.self, from: data)
                if decoded.sushi.isEmpty {
                    print("[YandexCatalog] Sushi API вернул пустой список")
                }
                DispatchQueue.main.async { completion(.success(decoded.sushi)) }
            } catch {
                print("[YandexCatalog] Sushi decode error: \(error)")
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    private func getSets(completion: @escaping (Result<[SushiSet], Error>) -> ()) {
        guard !YandexAPIConfig.baseURL.isEmpty, let url = URL(string: YandexAPIConfig.baseURL.hasSuffix("/") ? YandexAPIConfig.baseURL : YandexAPIConfig.baseURL + "/") else {
            DispatchQueue.main.async { completion(.failure(URLError(.badURL))) }
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        YandexAPIConfig.session.dataTask(with: request) { data, response, error in
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

// MARK: - YandexCatalogServiceProtocol

extension YandexCatalogService: YandexCatalogServiceProtocol {
    func loadCatalog(completion: @escaping (Result<([Sushi], [SushiSet]), Error>) -> Void) {
        let group = DispatchGroup()
        var sushiResult: Result<[Sushi], Error>?
        var setsResult: Result<[SushiSet], Error>?
        let lock = NSLock()

        group.enter()
        getSushi { result in
            lock.lock()
            sushiResult = result
            lock.unlock()
            group.leave()
        }

        group.enter()
        getSets { result in
            lock.lock()
            setsResult = result
            lock.unlock()
            group.leave()
        }

        group.notify(queue: .main) {
            lock.lock()
            let sushi = sushiResult
            let sets = setsResult
            lock.unlock()

            switch (sushi, sets) {
            case let (.success(s), .success(ss)):
                completion(.success((s, ss)))
            case let (.failure(e), _), let (_, .failure(e)):
                completion(.failure(e))
            default:
                completion(.failure(URLError(.unknown)))
            }
        }
    }
}
