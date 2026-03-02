//
//  YandexAPIConfig.swift
//  AsiaShop
//
//  Базовый URL и общая URLSession для Yandex Cloud API.
//

import Foundation

final class YandexAPIConfig {

    static let baseURL: String = "https://d5di93907ln32br63enu.emzafcgx.apigw.yandexcloud.net"

    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        return URLSession(configuration: config)
    }()

    /// Создаёт URLRequest. Для POST передать jsonBody — добавится Content-Type и body.
    func makeRequest(url: URL, method: String = "GET", jsonBody: Data? = nil) -> URLRequest {
        var request = URLRequest(url: url)
        request.httpMethod = method
        if let body = jsonBody {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            request.httpBody = body
        }
        return request
    }
}
