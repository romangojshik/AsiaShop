//
//  MainTabBar.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct MainTabBar: View {
    
    var viewModel: MainTapBarViewModel
    
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
            
            BasketView(viewModel: BasketViewModel.shared)
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

//struct MainTabBar_Previews: PreviewProvider {
//    static var previews: some View {
//        MainTabBar(viewModel: MainTapBarViewModel(user: <#T##User#>))
//    }
//}
