//
//  OrderStatus.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 6.12.23.
//

import Foundation

enum OrderStatus: String {
    case new = "New"
    case cooking = "Готовиться"
    case delivery = "Доставляется"
    case completed = "Выполнен"
    case cancelled = "Отменен"
}
