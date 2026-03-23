//
//  YandexCatalogService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 12/02/26.
//

import Foundation

// MARK: - ErrorLogEnum

private enum ErrorLogEnum {
    static func sushiError(_ error: Error) {
        print("[YandexCatalog] Rolls error: \(error.localizedDescription)")
    }
    static func sushiEmptyResponse() {
        print("[YandexCatalog] Rolls: empty response")
    }
    static func sushiHTTPError(_ statusCode: Int, _ body: String) {
        print("[YandexCatalog] Rolls HTTP \(statusCode): \(body.prefix(150))")
    }
    static func sushiEmptyList() {
        print("[YandexCatalog] Rolls API вернул пустой список")
    }
    static func sushiDecodeError(_ error: Error) {
        print("[YandexCatalog] Rolls decode error: \(error)")
    }
    static func setsError(_ error: Error) {
        print("[YandexCatalog] Ошибка: \(error.localizedDescription)")
    }
    static func setsEmptyResponse() {
        print("[YandexCatalog] Пустой ответ")
    }
    static func setsHTTPError(_ statusCode: Int, _ body: String) {
        print("[YandexCatalog] HTTP \(statusCode): \(body.prefix(150))")
    }
    static func setsEmptyList() {
        print("[YandexCatalog] API вернул пустой список")
    }
    static func setsDecodeError(_ error: Error) {
        print("[YandexCatalog] Ошибка декодирования: \(error)")
    }
}

// MARK: - YandexCatalogServiceProtocol

protocol YandexCatalogServiceProtocol {
    func loadCatalog(completion: @escaping (Result<([Roll], [RollSet]), Error>) -> Void)
}

final class YandexCatalogService {
    
    // MARK: - shared
    
    static let shared = YandexCatalogService()
    
    // MARK: - Private Properties
    
    private var yandexAPIConfig: YandexAPIConfig

    // MARK: - init
    
    private init(yandexAPIConfig: YandexAPIConfig = YandexAPIConfig()) {
        self.yandexAPIConfig = yandexAPIConfig
    }
    
    private func getRolls(completion: @escaping (Result<[Roll], Error>) -> ()) {
        guard
            !YandexAPIConfig.baseURL.isEmpty,
            let url = URL(string: (YandexAPIConfig.baseURL.hasSuffix("/") ? YandexAPIConfig.baseURL : YandexAPIConfig.baseURL + "/") + "rolls")
        else {
            DispatchQueue.main.async { completion(.failure(URLError(.badURL))) }
            return
        }

        let request = yandexAPIConfig.makeRequest(url: url)
        YandexAPIConfig.session.dataTask(with: request) { data, response, error in
            if let error = error {
                ErrorLogEnum.sushiError(error)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            
            guard let data = data else {
                ErrorLogEnum.sushiEmptyResponse()
                DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
                return
            }
            
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let body = String(data: data, encoding: .utf8) ?? ""
                ErrorLogEnum.sushiHTTPError(http.statusCode, body)
                let err = NSError(
                    domain: "YandexCatalogRolls",
                    code: http.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"]
                )
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            
            do {
                let decoded = try JSONDecoder().decode(RollsAPIResponse.self, from: data)
                if decoded.rolls.isEmpty {
                    ErrorLogEnum.sushiEmptyList()
                }
                DispatchQueue.main.async { completion(.success(decoded.rolls)) }
            } catch {
                ErrorLogEnum.sushiDecodeError(error)
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
    
    private func getSets(completion: @escaping (Result<[RollSet], Error>) -> ()) {
        guard
            !YandexAPIConfig.baseURL.isEmpty,
            let url = URL(string: YandexAPIConfig.baseURL.hasSuffix("/") ? YandexAPIConfig.baseURL : YandexAPIConfig.baseURL + "/")
        else {
            DispatchQueue.main.async { completion(.failure(URLError(.badURL))) }
            return
        }

        let request = yandexAPIConfig.makeRequest(url: url)
        YandexAPIConfig.session.dataTask(with: request) { data, response, error in
            if let error = error {
                ErrorLogEnum.setsError(error)
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                ErrorLogEnum.setsEmptyResponse()
                DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
                return
            }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let body = String(data: data, encoding: .utf8) ?? ""
                ErrorLogEnum.setsHTTPError(http.statusCode, body)
                let err = NSError(domain: "YandexCatalog", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode)"])
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            do {
                let decoded = try JSONDecoder().decode(CatalogAPIResponse.self, from: data)
                if decoded.sets.isEmpty {
                    ErrorLogEnum.setsEmptyList()
                }
                DispatchQueue.main.async { completion(.success(decoded.sets)) }
            } catch {
                ErrorLogEnum.setsDecodeError(error)
                DispatchQueue.main.async { completion(.failure(error)) }
            }
        }.resume()
    }
}

// MARK: - YandexCatalogServiceProtocol

extension YandexCatalogService: YandexCatalogServiceProtocol {
    func loadCatalog(completion: @escaping (Result<([Roll], [RollSet]), Error>) -> Void) {
        let group = DispatchGroup()
        var rollsResult: Result<[Roll], Error>?
        var setsResult: Result<[RollSet], Error>?
        let lock = NSLock()
        
        group.enter()
        getRolls { result in
            lock.lock()
            rollsResult = result
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
            let rolls = rollsResult
            let sets = setsResult
            lock.unlock()
            
            switch (rolls, sets) {
                case let (.success(r), .success(ss)):
                    completion(.success((r, ss)))
                case let (.failure(e), _), let (_, .failure(e)):
                    completion(.failure(e))
                default:
                    completion(.failure(URLError(.unknown)))
            }
        }
    }
}
