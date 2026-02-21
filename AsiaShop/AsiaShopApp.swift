//
//  AsiaShopApp.swift
//  AsiaShop
//
//  Created by Roman on 11/3/23.
//

import SwiftUI
import Firebase

let screen = UIScreen.main.bounds

@main
struct AsiaShopApp: App {
    
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    
    var body: some Scene {
        WindowGroup {
            //TODO: - для автризации
//            if let user = AuthService.shared.currentUser {
//                MainTabBar(viewModel: MainTapBarViewModel(user: user))
//            } else {
//                AuthView()
//            }
            MainTabBar()
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
        ) -> Bool {
            FirebaseApp.configure()
            // API Gateway не передаёт body в функцию — используйте URL HTTP-триггера функции:
            // Cloud Functions → asiashop-orders → Триггеры → создать HTTP-триггер (если нет) → скопировать URL сюда.
            YandexOrderService.shared.ordersAPIURL = "https://d5di93907ln32br63enu.emzafcgx.apigw.yandexcloud.net/order"
            // Альтернатива (подставить свой URL HTTP-триггера, например https://functions.yandexcloud.net/...):
            // YandexOrderService.shared.ordersAPIURL = "https://ВАШ_HTTP_ТРИГГЕР_URL"
            return true
        }
    }
}
