//
//  String+Extensions.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 1.03.26.
//

// MARK: - String

extension String {
    static func totalCost(_ value: Double) -> String {
        String(format: "Итоговая сумма: %.2f руб", value)
    }
}
