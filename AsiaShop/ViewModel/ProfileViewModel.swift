//
//  ProfileViewModel.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 5.12.23.
//

import Foundation

class ProfileViewModel: ObservableObject {
    @Published var profile: Profile
    @Published var orders: [Order] = [Order]()
    
    init(profile: Profile) {
        self.profile = profile
    }
    
    func setProfile() {
        DatabaseService.shared.setProfile(user: self.profile) { result in
            switch result {
            case .success(let user):
                print(user.name)
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getProfile() {
        DatabaseService.shared.getProfile { result in
            switch result {
            case .success(let user):
                self.profile = user
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getOrders() {
        DatabaseService.shared.getOrders(userID: AuthService.shared.currentUser!.accessibilityHint) { result in
            switch result {
            case .success(let orders ):
                self.orders = orders
                for (index, order) in self.orders.enumerated() {
                    DatabaseService.shared.getPositions(orderID: order.id) { result in
                        switch result {
                        case .success(let positions):
                            self.orders[index].positions = positions
                            print(self.orders[index].cost)
                        case .failure(let error):
                            print(error.localizedDescription)
                        }
                    }
                }
                print("Всего заказов: \(orders.count)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}
