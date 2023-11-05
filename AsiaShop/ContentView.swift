//
//  ContentView.swift
//  AsiaShop
//
//  Created by Roman on 11/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Авторизация")
                .bold()
                .padding()
                .padding(.horizontal, 30)
                .font(.title2)
                .background(Color("whiteAlpha"))
                .cornerRadius(30)
            
            VStack {
                TextField("Введите email", text: $email)
                    .padding()
                    .background(Color("whiteAlpha"))
                    .cornerRadius(12)
                    .padding(8)
                    .padding(.horizontal, 12)
                
                SecureField("Введите пароль", text: $password)
                    .padding()
                    .background(Color("whiteAlpha"))
                    .cornerRadius(12)
                    .padding(8)
                    .padding(.horizontal, 12)
                
                Button {
                    print("Авторизация")
                } label: {
                    Text("Войти")
                        .bold()
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(LinearGradient(gradient: Gradient(colors: [Color("yellow"), Color("orange")]), startPoint: .leading, endPoint: .trailing))
                        .cornerRadius(12)
                        .padding(8)
                        .padding(.horizontal, 12)
                        .font(.title3)
                        .foregroundColor(.black)
                }
                
                Button {
                    print("Регистрация")
                } label: {
                    Text("Регистрация")
                        .bold()
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity)
                        .cornerRadius(12)
                        .padding(8)
                        .padding(.horizontal, 12)
                        .font(.title3)
                        .foregroundColor(Color("orange"))
                }
            }
            .padding()
            .padding(.top, 15)
            .background(Color("whiteAlpha"))
            .cornerRadius(24)
            .padding()
            .padding(30)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Image("login_auth_v4")).ignoresSafeArea()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            ContentView()
            ContentView()
        }
    }
}
