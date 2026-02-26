//
//  Order.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 6.12.23.
//

import Foundation

enum OrderStatus: String {
    case new        = "Новый"
    case cooking    = "Готовиться"
    case delivery   = "Доставляется"
    case completed  = "Выполнен"
    case cancelled  = "Отменен"
}

struct Order: Identifiable {

    // MARK: - Stored properties

    var id: String = UUID().uuidString
    var userName: String              // имя клиента
    var numberPhone: String           // номер телефона

    var positions: [Position] = []    // позиции заказа
    var status: OrderStatus           // статус

    /// Сумма заказа, которую сохраняем в документе
    var total: Double

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
        status: OrderStatus = .new,
        createdAt: Date = Date(),
        readyBy: Date? = nil
    ) {
        self.id = id
        self.userName = userName
        self.numberPhone = numberPhone
        self.positions = positions
        self.status = status
        self.createdAt = createdAt
        self.readyBy = readyBy
        self.total = positions.reduce(0) { $0 + $1.cost }
    }
}
