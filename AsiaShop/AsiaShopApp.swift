//
//  AsiaShopApp.swift
//  AsiaShop
//
//  Created by Roman on 11/3/23.
//

import SwiftUI

let screen = UIScreen.main.bounds

@main
struct AsiaShopApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            MainTabBar()
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
        ) -> Bool {
            // ordersAPIURL по умолчанию = YandexAPIConfig.baseURL + "/order"
            // Чтобы изменить: YandexOrderService.shared.ordersAPIURL = "https://ваш-url/order"
            return true
        }
    }
}
