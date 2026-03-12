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
    
    var ordersAPIURL: String = YandexAPIConfig.baseURL + "/order"
    
    var isConfigured: Bool {
        !ordersAPIURL.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Private Properties
    
    private var yandexAPIConfig: YandexAPIConfig

    // MARK: - init
    
    private init(yandexAPIConfig: YandexAPIConfig = YandexAPIConfig()) {
        self.yandexAPIConfig = yandexAPIConfig
    }
    
    private func orderPayload(_ order: Order) -> Data? {
        var dict: [String: Any] = [
            "id": order.id,
            "user_name": order.userName,
            "user_phone_number": order.numberPhone,
            "total": order.total,
        ]
        if !order.extras.isEmpty {
            dict["extras"] = order.extras
        }
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

        let request = yandexAPIConfig.makeRequest(url: url, method: "POST", jsonBody: body)
        
        let (_, response) = try await YandexAPIConfig.session.data(for: request)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            let statusCode = (response as? HTTPURLResponse)?.statusCode ?? 0
            throw NSError(domain: "YandexOrder", code: statusCode, userInfo: [NSLocalizedDescriptionKey: "HTTP \(statusCode)"])
        }

        return order
    }
}
