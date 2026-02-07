//
//  Order.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 6.12.23.
//

import FirebaseFirestore

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

    var representation: [String: Any] {
        var repres: [String: Any] = [:]

        repres["id"] = id
        repres["userName"] = userName
        repres["numberPhone"] = numberPhone
        repres["status"] = status.rawValue
        repres["total"] = total
        repres["createdAt"] = Timestamp(date: createdAt)

        if let readyBy {
            repres["readyBy"] = Timestamp(date: readyBy)
        }

        return repres
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

    // MARK: - Init из документа Firestore

    init?(document: QueryDocumentSnapshot) {
        let data = document.data()

        guard
            let id = data["id"] as? String,
            let userName = data["userName"] as? String,
            let numberPhone = data["numberPhone"] as? String,
            let statusRaw = data["status"] as? String,
            let total = data["total"] as? Double,
            let createdAtTs = data["createdAt"] as? Timestamp
        else {
            return nil
        }

        self.id = id
        self.userName = userName
        self.numberPhone = numberPhone
        self.total = total
        self.createdAt = createdAtTs.dateValue()
        self.readyBy = (data["readyBy"] as? Timestamp)?.dateValue()

        self.status = OrderStatus(rawValue: statusRaw) ?? .new

        // Позиции обычно подтягиваются отдельным запросом из подколлекции
        self.positions = []
    }
}
