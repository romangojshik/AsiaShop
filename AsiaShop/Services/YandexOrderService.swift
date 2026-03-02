//
//  YandexOrderService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 12/02/26.
//

import Foundation

// MARK: - YandexCatalogServiceProtocol

protocol YandexOrderServiceProtocol {
    func submitOrder(_ order: Order,completion: @escaping (Result<Order, Error>) -> Void)
}

/// Сервис отправки заказов в Yandex Cloud Function (orders-api).
final class YandexOrderService {
    
    static let shared = YandexOrderService()
    
    /// URL API заказов. По умолчанию baseURL + "/order". Можно переопределить в AppDelegate.
    var ordersAPIURL: String = YandexAPIConfig.baseURL + "/order"
    
    private init() {}
    
    var isConfigured: Bool {
        !ordersAPIURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func orderPayload(_ order: Order) -> Data? {
        let dict: [String: Any] = [
            "id": order.id,
            "user_name": order.userName,
            "user_phone_number": order.numberPhone,
            "total": order.total,
        ]
        return try? JSONSerialization.data(withJSONObject: dict)
    }
}

extension YandexOrderService: YandexOrderServiceProtocol {
    /// Отправляет заказ на orders-api. В тело уходят только id, user_name, user_phone_number, total.
    func submitOrder(_ order: Order,completion: @escaping (Result<Order, Error>) -> Void) {
        let base = ordersAPIURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isConfigured, let url = URL(string: base.hasSuffix("/") ? base : base + "/") else {
            completion(.failure(URLError(.badURL)))
            return
        }
        
        guard let body = orderPayload(order) else {
            print("[YandexOrder] Ошибка: не удалось собрать payload заказа")
            DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
            return
        }
        if let json = String(data: body, encoding: .utf8) {
            print("[YandexOrder] Отправляем поля:", json)
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body
        
        YandexAPIConfig.session.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async { completion(.failure(error)) }
                return
            }
            guard let data = data else {
                DispatchQueue.main.async { completion(.failure(URLError(.cannotParseResponse))) }
                return
            }
            if let http = response as? HTTPURLResponse, http.statusCode != 200 {
                let msg = String(data: data, encoding: .utf8) ?? ""
                let err = NSError(domain: "YandexOrder", code: http.statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(http.statusCode): \(msg)"])
                DispatchQueue.main.async { completion(.failure(err)) }
                return
            }
            DispatchQueue.main.async { completion(.success(order)) }
        }.resume()
    }
}
