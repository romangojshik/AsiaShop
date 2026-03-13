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
    @StateObject private var orderDataStorage = OrderDataStorage()
    
    var body: some Scene {
        WindowGroup {
            MainTabBar()
                .environmentObject(orderDataStorage)
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
        ) -> Bool {
            return true
        }
    }
}
