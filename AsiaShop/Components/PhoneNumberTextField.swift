//
//  PhoneNumberTextField.swift
//  AsiaShop
//
//  Маска телефона +375 (XX) XXX-XX-XX на основе подхода из
//  https://github.com/bullinnyc/PhoneTextField
//

import SwiftUI

// MARK: - Phone field view (SwiftUI, маска +375)

struct PhoneFieldView: View {
    @State private var text = ""
    @State private var isFormatting = false
    @FocusState private var isFocused: Bool
    
    private let placeholder: String
    private let countryCode: String
    private let title: String?
    private let keyboardType: UIKeyboardType
    private let binding: Binding<String>
    
    /// Маска: +375 и 9 цифр в виде (XX) XXX-XX-XX
    private let mask = "+XXX (XX) XXX-XX-XX"
    
    private var internationalCode: String {
        "+" + countryCode
    }
    
    /// Показывать подсказку формата, пока пользователь не ввёл ни одной цифры (в т.ч. когда уже отображается «+375 »).
    private var showFormatPlaceholder: Bool {
        let digits = text.filteredPhoneDigits
        let userDigits = digits.count > countryCode.count ? String(digits.dropFirst(countryCode.count)) : ""
        return userDigits.isEmpty
    }
    
    /// Не введённая часть маски — показываем серым сразу после введённого текста.
    private var maskSuffix: String {
        guard text.count < mask.count else { return "" }
        return String(mask.dropFirst(text.count))
    }

    /// Префикс до первой цифры пользователя: "+375 " или "+375 (" (при пустом вводе).
    private var countryPrefix: String {
        internationalCode + " "
    }

    /// Часть текста после кода страны (для отдельной окраски).
    private var textAfterCountryCode: String {
        guard text.hasPrefix(countryPrefix) else { return text }
        return String(text.dropFirst(countryPrefix.count))
    }

    /// Текст "+375 (" — для чёрной окраски при фокусе без ввода.
    private var countryCodeWithBracket: String {
        internationalCode + " ("
    }
    
    init(
        placeholder: String = "",
        countryCode: String = "375",
        title: String? = nil,
        keyboardType: UIKeyboardType = .phonePad,
        text: Binding<String>
    ) {
        self.placeholder = placeholder
        self.countryCode = countryCode
        self.title = title
        self.keyboardType = keyboardType
        self.binding = text
        let userDigits = text.wrappedValue.phoneDigitsOnly.prefix(9)
        let formatted = Self.formattedNumber(digits: String(userDigits), countryCode: countryCode, mask: "+XXX (XX) XXX-XX-XX")
        _text = State(wrappedValue: formatted.isEmpty ? "" : formatted)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            if let title = title {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundStyle(.black.opacity(0.9))
            }
            
            ZStack(alignment: .leading) {
                if showFormatPlaceholder && !isFocused {
                    Text(placeholder.isEmpty ? "+375 (XX) XXX-XX-XX" : placeholder)
                        .foregroundColor(.gray)
                        .padding(.leading, 8)
                }
                TextField("", text: $text)
                    .keyboardType(keyboardType)
                    .autocorrectionDisabled()
                    .focused($isFocused)
                    .foregroundColor(.clear)
                    .tint(.black)
                    .padding(.horizontal, 8)
                    .overlay(
                        Group {
                            if showFormatPlaceholder && isFocused {
                                HStack(spacing: 0) {
                                    Text(countryCodeWithBracket)
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Text(maskSuffix)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8)
                                .allowsHitTesting(false)
                            } else if !showFormatPlaceholder {
                                HStack(spacing: 0) {
                                    Text(countryPrefix)
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Text(textAfterCountryCode)
                                        .font(.body)
                                        .foregroundColor(.black)
                                    Text(maskSuffix)
                                        .font(.body)
                                        .foregroundColor(.gray)
                                }
                                .padding(.leading, 8)
                                .allowsHitTesting(false)
                            }
                        },
                        alignment: .leading
                    )
            }
                .onChange(of: text) { newValue in
                    guard !isFormatting else { return }
                    isFormatting = true
                    defer { isFormatting = false }

                    let digits = newValue.filteredPhoneDigits
                    let userDigits = String(digits.dropFirst(countryCode.count)).prefix(9)
                    let formatted = Self.formattedNumber(
                        digits: String(userDigits),
                        countryCode: countryCode,
                        mask: mask
                    )
                    if formatted != newValue {
                        text = formatted
                    }
                    let raw = String(userDigits)
                    if binding.wrappedValue != raw {
                        binding.wrappedValue = raw
                    }
                }
        }
        .onChange(of: isFocused) { focused in
            if focused && text.isEmpty {
                text = internationalCode + " ("
            }
        }
    }
    
    private static func formattedNumber(digits: String, countryCode: String, mask: String) -> String {
        let full = (countryCode + digits).filteredPhoneDigits
        let numbers = String(full.prefix(12))
        if numbers.isEmpty { return "" }
        if numbers == countryCode {
            return "+" + countryCode + " ("
        }

        var result = ""
        var index = numbers.startIndex

        for ch in mask where index < numbers.endIndex {
            if ch == "X" {
                result.append(numbers[index])
                index = numbers.index(after: index)
            } else {
                result.append(ch)
            }
        }
        return result
    }
}

// MARK: - String helpers

private extension String {
    var filteredPhoneDigits: String {
        filter { "0123456789".contains($0) }
    }
}

// MARK: - Digits for validation (для проверки «пустой / неполный»)

enum PhoneMask {
    static func digits(from formatted: String) -> String {
        formatted.filteredPhoneDigits
    }
}

extension String {
    var phoneDigitsOnly: String {
        filter { "0123456789".contains($0) }
    }
}
