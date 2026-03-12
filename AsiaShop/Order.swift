//
//  Order.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 6.12.23.
//

import Foundation

struct Order: Identifiable {

    // MARK: - Stored properties

    var id: String = UUID().uuidString
    var userName: String              // имя клиента
    var numberPhone: String           // номер телефона

    var positions: [Position] = []    // позиции заказа

    /// Сумма заказа, которую сохраняем в документе
    var total: Double

    /// Дополнения: название → количество. В JSON уходит как объект, например {"Васаби": 1, "Палочки": 2}.
    var extras: [String: Int] = [:]

    /// Когда заказ создан
    var createdAt: Date

    /// К какому времени нужно приготовить суши (опционально)
    var readyBy: Date?

    // MARK: - Computed properties

    /// Пересчёт суммы по позициям (если нужно)
    var cost: Double {
        positions.reduce(0) { $0 + $1.cost }
    }

    init(
        id: String = UUID().uuidString,
        userName: String,
        numberPhone: String,
        positions: [Position] = [],
        createdAt: Date = Date(),
        readyBy: Date? = nil,
        total: Double? = nil,
        extras: [String: Int] = [:]
    ) {
        self.id = id
        self.userName = userName
        self.numberPhone = numberPhone
        self.positions = positions
        self.createdAt = createdAt
        self.readyBy = readyBy
        self.total = total ?? positions.reduce(0) { $0 + $1.cost }
        self.extras = extras
    }
}
