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
            AuthView()
        }
    }
    
    class AppDelegate: NSObject, UIApplicationDelegate {
        func application(
            _ application: UIApplication,
            didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
        ) -> Bool {
            FirebaseApp.configure()
            print("Ok")
            return true
        }
    }
}
