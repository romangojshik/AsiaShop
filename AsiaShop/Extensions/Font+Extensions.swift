//
//  Font+Extensions.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 28.02.26.
//

import SwiftUI

extension Font {
    /// Создаёт системный шрифт с указанным размером и начертанием.
    static func app(size: CGFloat, weight: Font.Weight = .regular) -> Font {
        .system(size: size, weight: weight)
    }
    
    // MARK: - Готовые шрифты

    static let titleFont = Font.app(size: 20, weight: .bold)
    static let titleDescriptionFont = Font.app(size: 14, weight: .semibold)
    static let titleTextFont = Font.app(size: 16, weight: .medium)
    static let buttonFont = Font.app(size: 16, weight: .bold)
    static let descriptionFont = Font.app(size: 14, weight: .regular)
}
