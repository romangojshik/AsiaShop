//
//  Profile.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 3.12.23.
//

import Foundation

struct Profile: Identifiable {
    var id: String
    var name: String
    var phone: Int
    var address: String
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        repres["id"] = self.id
        repres["name"] = self.name
        repres["phone"] = self.phone
        repres["address"] = self.address
        
        return repres
    }
}
