//
//  MainTabBar.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

enum Tab: Hashable {
    case catalog
    case basket
}

struct MainTabBar: View {
    @StateObject private var viewModel = MainTapBarViewModel()
    @State private var selectedTab: Tab = .catalog
    
    init() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(white: 0.15, alpha: 1.0)

        UITabBar.appearance().standardAppearance = appearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = appearance
        }

        UITabBar.appearance().unselectedItemTintColor = .gray
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationView {
                CatalogView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image("catalog")
                        .renderingMode(.template)
                    Text("Каталог")
                }
            }
            .tag(Tab.catalog)
            
            BasketView()
                .tabItem {
                    VStack {
                        Image("basket")
                            .renderingMode(.template)
                        Text("Корзина")
                    }
                }
            .tag(Tab.basket)
        }
        .environmentObject(OrderDataStorage.shared)
        .tint(.white)
    }
}
