//
//  BasketRouter.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import SwiftUI

// MARK: - Navigation Routes
enum BasketRoute: Identifiable {
    case confirmOrder(totalCost: Double)
    case orderAccepted(userPhone: String)
    
    var id: String {
        switch self {
        case .confirmOrder(let totalCost):
            return "confirmOrder_\(totalCost)"
        case .orderAccepted(let phone):
            return "orderAccepted_\(phone)"
        }
    }
}

// MARK: - Router Protocol
protocol BasketRouterProtocol: ObservableObject {
    var currentRoute: BasketRoute? { get set }
    func navigate(to route: BasketRoute)
    func dismiss()
}

// MARK: - Router Implementation
class BasketRouter: BasketRouterProtocol {
    @Published var currentRoute: BasketRoute?
    
    func navigate(to route: BasketRoute) {
        currentRoute = route
    }
    
    func dismiss() {
        currentRoute = nil
    }
}
