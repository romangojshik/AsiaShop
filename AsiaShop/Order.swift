//
//  Order.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 6.12.23.
//

import FirebaseFirestore

struct Order {
    var id: String = UUID().uuidString
    var userID: String
    var positions = [Position]()
    var date: Date
    var status: String
    
    var cost: Double {
        var sum = 0.0
        
        for position in positions {
            sum += position.cost
        }
        
        return sum
    }
    
    var representation: [String: Any] {
        var repres = [String: Any]()
        
        repres["id"] = id
        repres["userID"] = userID
        repres["date"] = Timestamp(date: date)
        repres["status"] = status
        
        return repres
    }
    
}
