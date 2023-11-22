//
//  MainTabBar.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct MainTabBar: View {
    var body: some View {
        TabView {
            NavigationView {
                CatalogView()
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image("catalog_32")
                    Text("Каталог")
                }
            }
            
            BasketView()
                .tabItem {
                    VStack {
                        Image("backet_32")
                        Text("Корзина")
                    }
                }
            
            ProvileView()
                .tabItem {
                    VStack {
                        Image("profile_32")
                        Text("Профиль")
                    }
                }
        }
    }
}

struct MainTabBar_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBar()
    }
}
