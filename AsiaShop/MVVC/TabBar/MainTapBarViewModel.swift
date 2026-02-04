//
//  MainTapBarViewModel.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01/12/25.
//

import Foundation
import FirebaseAuth

class MainTapBarViewModel: ObservableObject {
    @Published var user: User?
    
    init(user: User? = nil) {
        self.user = user
    }
}
