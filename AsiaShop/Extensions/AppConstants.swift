//
//  AppConstants.swift
//  AsiaShop
//
//  Глобальные константы приложения
//

import SwiftUI

enum AppConstants {
    enum Colors {
        static let blackOpacity70 = Color.black.opacity(0.7)
        static let blackOpacity90 = Color.black.opacity(0.9)
    }
    
    enum Padding {
        static let padding2 = 2.0
        static let padding4 = 4.0
        static let padding6 = 6.0
        static let padding8 = 8.0
        static let padding10 = 10.0
        static let padding12 = 12.0
        static let padding16 = 16.0
        static let padding18 = 18.0
        static let padding24 = 24.0
        static let padding32 = 32.0
    }
    
    enum Size {
        static let productImage = CGSize(width: 96, height: 96)
    }
}
