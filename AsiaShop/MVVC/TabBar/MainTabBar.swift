//
//  MainTabBar.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct MainTabBar: View {
    
    var viewModel: MainTapBarViewModel
    
    @StateObject private var basketVM = BasketViewModel()
    
    var body: some View {
        TabView {
            NavigationView {
                CatalogView(basket: basketVM)
            }
            .navigationViewStyle(StackNavigationViewStyle())
            .tabItem {
                VStack {
                    Image("catalog_32")
                    Text("Каталог")
                }
            }
            
            BasketView(viewModel: basketVM)
                .tabItem {
                    VStack {
                        Image("backet_32")
                        Text("Корзина")
                    }
                }
            
            ProvileView(viewModel: ProfileViewModel(
                profile: .init(
                    id: "",
                    name: "",
                    phone: 0,
                    address: ""
                )
            ))
            .tabItem {
                VStack {
                    Image("profile_32")
                    Text("Профиль")
                }
            }
        }
    }
}
