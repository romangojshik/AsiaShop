//
//  YandexOrderService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 12/02/26.
//

import Foundation

// MARK: - YandexOrderServiceProtocol

protocol YandexOrderServiceProtocol {
    func submitOrder(_ order: Order) async throws -> Order
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

// MARK: - YandexOrderServiceProtocol

extension YandexOrderService: YandexOrderServiceProtocol {
    func submitOrder(_ order: Order) async throws -> Order {
        let base = ordersAPIURL.trimmingCharacters(in: .whitespacesAndNewlines)
        guard isConfigured, let url = URL(string: base.hasSuffix("/") ? base : base + "/") else {
            throw URLError(.badURL)
        }

        guard let body = orderPayload(order) else {
            print("[YandexOrder] Ошибка: не удалось собрать payload заказа")
            throw URLError(.cannotParseResponse)
        }
        
        if let json = String(data: body, encoding: .utf8) {
            print("[YandexOrder] Отправляем поля:", json)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = body

        let (_, response) = try await YandexAPIConfig.session.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw NSError(domain: "YandexOrder", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode)"])
        }

        return order
    }
}
