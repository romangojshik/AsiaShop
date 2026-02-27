//
//  DatabaseService.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 3.12.23.
//

import Foundation

protocol DatabaseServiceProtocol {
    func getSushi(completion: @escaping (Result<[Sushi], Error>) -> Void)
    func getSets(completion: @escaping (Result<[SushiSet], Error>) -> Void)
}
