//
//  Nutrition.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 8.02.26.
//

import Foundation

struct Nutrition: Decodable {
    var weight: String?
    var callories: String?
    var proteins: String?
    var fats: String?
    var carbs: String?

    init(
        weight: String? = nil,
        callories: String? = nil,
        proteins: String? = nil,
        fats: String? = nil,
        carbs: String? = nil
    ) {
        self.weight = weight
        self.callories = callories
        self.proteins = proteins
        self.fats = fats
        self.carbs = carbs
    }

    private enum CodingKeys: String, CodingKey {
        case weight
        case callories
        case proteins
        case fats
        case carbs
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        self.weight = Nutrition.decodeString(for: .weight, from: container)
        self.callories = Nutrition.decodeString(for: .callories, from: container)
        self.proteins = Nutrition.decodeString(for: .proteins, from: container)
        self.fats = Nutrition.decodeString(for: .fats, from: container)
        self.carbs = Nutrition.decodeString(for: .carbs, from: container)
    }

    /// Инициализация из JSON-словаря (ответ API Yandex и т.п.).
    init(from data: [String: Any]?) {
        self.weight = Nutrition.anyToString(data?["weight"])
        self.callories = Nutrition.anyToString(data?["callories"])
        self.proteins = Nutrition.anyToString(data?["proteins"])
        self.fats = Nutrition.anyToString(data?["fats"])
        self.carbs = Nutrition.anyToString(data?["carbs"])
    }

    private static func decodeString(
        for key: CodingKeys,
        from container: KeyedDecodingContainer<CodingKeys>
    ) -> String? {
        if let stringValue = try? container.decodeIfPresent(String.self, forKey: key) {
            return stringValue
        }
        if let intValue = try? container.decodeIfPresent(Int.self, forKey: key) {
            return String(intValue)
        }
        if let doubleValue = try? container.decodeIfPresent(Double.self, forKey: key) {
            if doubleValue.rounded() == doubleValue {
                return String(Int(doubleValue))
            }
            return String(doubleValue)
        }
        return nil
    }

    private static func anyToString(_ value: Any?) -> String? {
        switch value {
        case let stringValue as String:
            return stringValue
        case let intValue as Int:
            return String(intValue)
        case let doubleValue as Double:
            if doubleValue.rounded() == doubleValue {
                return String(Int(doubleValue))
            }
            return String(doubleValue)
        default:
            return nil
        }
    }
}
