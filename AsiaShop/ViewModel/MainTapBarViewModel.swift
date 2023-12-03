//
//  MainTapBarViewModel.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 1.12.23.
//

import Foundation
import FirebaseAuth

class MainTapBarViewModel: ObservableObject {
    @Published var user: User
    
    init(user: User) {
        self.user = user
    }
}
