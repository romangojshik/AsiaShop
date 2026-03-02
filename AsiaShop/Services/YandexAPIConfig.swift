//
//  YandexAPIConfig.swift
//  AsiaShop
//
//  Базовый URL и общая URLSession для Yandex Cloud API.
//

import Foundation

enum YandexAPIConfig {

    static let baseURL: String = "https://d5di93907ln32br63enu.emzafcgx.apigw.yandexcloud.net"

    static let session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 15
        return URLSession(configuration: config)
    }()
}
