//
//  String+Extensions.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 1.03.26.
//

// MARK: - String

extension String {
    static var empty: String { "" }
    
    /// Возвращает строку с суффиксом " г", или пустую строку если self пустой
    var withGrams: String {
        isEmpty ? "" : self + " г"
    }
    
    static func totalCost(_ value: Double) -> String {
        String(format: "Итоговая сумма: %.2f руб", value)
    }
    
    static func costForSyshi(_ value: Double) -> String {
        String(format:  "%.0f руб.", value)
    }
}

extension Optional where Wrapped == String {
    var orEmpty: String { self ?? "" }
}
