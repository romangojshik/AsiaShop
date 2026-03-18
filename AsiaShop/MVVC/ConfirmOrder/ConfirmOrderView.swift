//
//  ConfirmOrderView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI


struct ConfirmOrderView: View {
    @ObservedObject var viewModel: ConfirmOrderViewModel
    @State private var isConfirmButtonDisabled = false
    @State private var selectedDay: DeliveryDay = .today
    @State private var selectedHour: Int = 10
    @State private var selectedMinute: Int = 0
    @State private var didInitializeTime = false
    @State private var minTodaySlot: Date = Date()
    
    private let fromHour: Int = 10
    private let toHour: Int = 22
    private let minuteStep: Int = 10
    private let minuteOptions = [0, 10, 20, 30, 40, 50]
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppConstants.Padding.padding24) {
                Text(Constants.Texts.confirmText)
                    .font(.titleFont)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                    .padding(.top, AppConstants.Padding.padding16)
                
                Text(String.totalCost(viewModel.totalCost))
                    .font(.titleFont)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                
                
                makeInputField(
                    title: Constants.Texts.enterUserName,
                    placeholder: Constants.Texts.namePlaceholder,
                    text: $viewModel.userName,
                    textContentType: .name,
                    validateEmpty: false,
                    showValidationError: false
                )
                
                makePhoneInputField(
                    title: Constants.Texts.enterUserPhone,
                    placeholder: Constants.Texts.userPhonePlaceholder,
                    text: $viewModel.phone,
                    validateEmpty: false,
                    showValidationError: false
                )
                
                makeDetaPickerSection
                
                makeConfirmSection
            }
            .padding(AppConstants.Padding.padding16)
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
            }
        }
        .ignoresSafeArea(.keyboard)
        .padding(.bottom, AppConstants.Padding.padding16)
        .onAppear {
            guard !didInitializeTime else { return }
            didInitializeTime = true
            
            let now = Date()
            let cal = Calendar.current
            
            // минимальный слот "сегодня" = сейчас + 20 минут,
            // затем округляем вверх к ближайшему 10-минутному слоту,
            // но если попадаем в "хвост" часа (минуты > 40) — переносим на начало следующего часа.
            let minBase = now.addingTimeInterval(20 * 60)
            var compsMin = cal.dateComponents([.year, .month, .day, .hour, .minute], from: minBase)
            let rawMinute = compsMin.minute ?? 0
            let rawHour = compsMin.hour ?? fromHour
            if rawMinute == 0 {
                compsMin.minute = 0
                compsMin.hour = rawHour
            } else if rawMinute <= 40 {
                // округляем вверх к шагу 10 минут в текущем часе
                let stepped = ((rawMinute + (minuteStep - 1)) / minuteStep) * minuteStep
                compsMin.minute = stepped
                compsMin.hour = rawHour
            } else {
                // считаем, что уже поздно в этом часе — переносим на начало следующего
                compsMin.minute = 0
                compsMin.hour = rawHour + 1
            }
            minTodaySlot = cal.date(from: compsMin) ?? minBase
            
            let base = viewModel.readyBy ?? minTodaySlot
            
            let today = cal.startOfDay(for: now)
            selectedDay = cal.startOfDay(for: base) > today ? .tomorrow : .today
            
            // Для завтра всегда начинать минимум с 11:00
            if selectedDay == .tomorrow {
                selectedHour = 11
                selectedMinute = 0
            } else {
                // Выставляем час/минуты из base, затем зажимаем в доступные значения
                let comps = cal.dateComponents([.hour, .minute], from: base)
                selectedHour = comps.hour ?? fromHour
                selectedMinute = roundMinuteToStep(comps.minute ?? 0)
            }
            clampSelectionToAvailable()
        }
    }
    
    private func makeInputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        textContentType: UITextContentType,
        keyboardType: UIKeyboardType = .default,
        validateEmpty: Bool = false,
        showValidationError: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding16) {
            Text(title)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            ZStack(alignment: .leading) {
                if text.wrappedValue.isEmpty {
                    Text(placeholder)
                        .foregroundColor(.gray)
                        .padding(AppConstants.Padding.padding10)
                        .allowsHitTesting(false)
                }
                TextField("", text: text)
                    .foregroundColor(AppConstants.Colors.blackOpacity90)
                    .tint(.black)
                    .keyboardType(keyboardType)
                    .textContentType(textContentType)
                    .padding(AppConstants.Padding.padding10)
            }
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Padding.padding8)
                    .stroke(
                        validateEmpty && showValidationError && text.wrappedValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
                        ? Color.red
                        : .black,
                        lineWidth: 1
                    )
            )
        }
    }
    
    private func makePhoneInputField(
        title: String,
        placeholder: String,
        text: Binding<String>,
        validateEmpty: Bool = false,
        showValidationError: Bool = false
    ) -> some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding16) {
            Text(title)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            PhoneFieldView(
                placeholder: placeholder,
                countryCode: "375",
                title: nil,
                keyboardType: .phonePad,
                text: text
            )
            .padding(AppConstants.Padding.padding10)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.Padding.padding8)
                    .stroke(
                        validateEmpty && showValidationError && PhoneMask.digits(from: text.wrappedValue).isEmpty
                        ? Color.red
                        : .black,
                        lineWidth: 1
                    )
            )
        }
    }
    
    private var makeDetaPickerSection: some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding8) {
            Text(Constants.Texts.detaPickerTitle)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            HStack {
                // День: Сегодня / Завтра (оставим wheel, но корректно сбрасываем время)
                Picker("День", selection: $selectedDay) {
                    ForEach(DeliveryDay.allCases) { day in
                        Text(day.rawValue).tag(day)
                    }
                }
                .pickerStyle(.wheel)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
                .tint(.black)
                .frame(maxWidth: .infinity)
                .onChange(of: selectedDay) { _ in
                    if selectedDay == .tomorrow {
                        // При переходе на завтра всегда начинаем с 11:00
                        selectedHour = 11
                        selectedMinute = 0
                    }
                    clampSelectionToAvailable()
                }
                
                // Часы
                Picker("Часы", selection: $selectedHour) {
                    ForEach(availableHours, id: \.self) { hour in
                        Text(String(format: "%02d", hour)).tag(hour)
                    }
                }
                .pickerStyle(.wheel)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
                .tint(.black)
                .frame(maxWidth: .infinity)
                .onChange(of: selectedHour) { _ in
                    clampSelectionToAvailable()
                }
                
                // Минуты (шаг 10)
                Picker("Минуты", selection: $selectedMinute) {
                    ForEach(availableMinutes, id: \.self) { minute in
                        Text(String(format: "%02d", minute)).tag(minute)
                    }
                }
                .pickerStyle(.wheel)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
                .tint(.black)
                .frame(maxWidth: .infinity)
                .onChange(of: selectedMinute) { _ in
                    clampSelectionToAvailable()
                }
            }
            .frame(height: 180)
            .environment(\.colorScheme, .light)
            
            Text(summaryTimeText)
                .font(.subheadline)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
                .frame(maxWidth: .infinity, alignment: .center)
        }
    }
    
    private var makeConfirmSection: some View {
        VStack(spacing: AppConstants.Padding.padding12) {
            Text(Constants.Texts.confirmTitle)
                .font(.titleTextFont)
                .foregroundColor(AppConstants.Colors.blackOpacity90)
            
            HStack(spacing: AppConstants.Padding.padding16) {
                WhiteOrBlackButton(
                    title: Constants.Texts.cancel,
                    backgroundColor: AppConstants.Colors.blackOpacity90,
                    foregroundColor: .white,
                    action: {
                        viewModel.cancelOrder()
                    }
                )
                
                WhiteOrBlackButton(
                    title: Constants.Texts.confirm,
                    backgroundColor: AppConstants.Colors.blackOpacity90,
                    foregroundColor: .white,
                    action: {
                        isConfirmButtonDisabled = true
                        viewModel.readyBy = buildSelectedDate()
                        viewModel.confirmOrder()
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            isConfirmButtonDisabled = false
                        }
                    }
                )
                .disabled(isConfirmButtonDisabled || !viewModel.isFormValid)
                .opacity((isConfirmButtonDisabled || !viewModel.isFormValid) ? 0.6 : 1)
            }
        }
    }
    
    private func buildSelectedDate() -> Date {
        let calendar = Calendar.current
        let now = Date()
        
        let baseDay: Date = {
            switch selectedDay {
            case .today:
                return now
            case .tomorrow:
                return calendar.date(byAdding: .day, value: 1, to: now) ?? now
            }
        }()
        
        var comps = calendar.dateComponents([.year, .month, .day], from: baseDay)
        comps.hour = selectedHour
        comps.minute = selectedMinute
        
        let selected = calendar.date(from: comps) ?? now
        
        // Ограничение: "Сегодня" не может быть раньше текущего времени (округляем вверх до шага)
        if selectedDay == .today {
            let minAllowed = roundedUp(now, stepMinutes: minuteStep)
            return max(selected, minAllowed)
        }
        
        return selected
    }
    
    private var summaryTimeText: String {
        let date = buildSelectedDate()
        let formatter = DateFormatter()
        formatter.locale = Constants.LocaleSettings.russian
        formatter.dateFormat = "d MMMM yyyy, HH:mm"
        let full = formatter.string(from: date)
        return full
    }
    
    private var availableHours: [Int] {
        switch selectedDay {
        case .tomorrow:
            // Для завтра — с 11:00
            return Array(11...toHour)
        case .today:
            let calendar = Calendar.current
            let min = minTodaySlot
            let minHour = calendar.component(.hour, from: min)
            let start = max(fromHour, minHour)
            if start > toHour { return [] }
            return Array(start...toHour)
        }
    }
    
    private var availableMinutes: [Int] {
        let minutes = minuteOptions
        guard selectedDay == .today else { return minutes }
        let calendar = Calendar.current
        let min = minTodaySlot
        let minHour = calendar.component(.hour, from: min)
        let minMinute = calendar.component(.minute, from: min)
        if selectedHour == minHour {
            return minutes.filter { $0 >= minMinute }
        }
        return minutes
    }
    
    private func clampSelectionToAvailable() {
        // если сегодня уже после рабочего времени — переключаем на завтра (10:00)
        if selectedDay == .today, availableHours.isEmpty {
            selectedDay = .tomorrow
            selectedHour = 11
            selectedMinute = minuteOptions.first ?? 0
            return
        }
        
        let hours = availableHours
        if !hours.isEmpty, !hours.contains(selectedHour) {
            selectedHour = hours.first ?? selectedHour
        }
        
        let minutes = availableMinutes
        if minutes.isEmpty {
            selectedMinute = minuteOptions.first ?? 0
        } else if !minutes.contains(selectedMinute) {
            selectedMinute = minutes.first ?? selectedMinute
        }
    }
    
    private func roundedUp(_ date: Date, stepMinutes: Int) -> Date {
        let step = TimeInterval(stepMinutes * 60)
        return Date(timeIntervalSince1970: ceil(date.timeIntervalSince1970 / step) * step)
    }
    
    private func roundMinuteToStep(_ minute: Int) -> Int {
        let m = max(0, min(59, minute))
        let rounded = Int((Double(m) / Double(minuteStep)).rounded()) * minuteStep
        return min(rounded, 50)
    }
}

// MARK: - Constants

private struct Constants {
    struct Images {}
    
    struct Texts {
        static let confirmText = "Подтверждение заказа"
        static let detaPickerTitle = "К какому времени приготовить ваш заказ"
        static let enterUserName = "Введите ваше имя *"
        static let namePlaceholder = "Имя"
        static let enterUserPhone = "Введите номер телефона для подтверждения заказа *"
        static let userPhonePlaceholder = "+375 (XX) XXX-XX-XX"
        static let confirmTitle = "Вы хотите оформить заказ?"
        static let cancel = "Отмена"
        static let confirm = "Подтвердить"
    }
    
    struct LocaleSettings {
        static let russian = Locale(identifier: "ru_RU")
    }
}

// MARK: - DeliveryDay

private enum DeliveryDay: String, CaseIterable, Identifiable {
    case today = "Сегодня"
    case tomorrow = "Завтра"
    
    var id: String { rawValue }
}
