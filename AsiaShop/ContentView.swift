//
//  ContentView.swift
//  AsiaShop
//
//  Created by Roman on 11/3/23.
//

import SwiftUI

struct ContentView: View {
    @State private var isAuth = true
    @State private var confirmPassword = ""
    
    @State private var email = ""
    @State private var password = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text(isAuth ? "Авторизация" : "Регистрация")
                .bold()
                .padding(isAuth ? 15 : 35)
                .padding(.horizontal, 30)
                .font(.title2)
                .background(Color("whiteAlpha"))
                .cornerRadius(isAuth ? 30 : 60)
            
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
                
                if !isAuth {
                    SecureField("Повторите пароль", text: $confirmPassword)
                        .padding()
                        .background(Color("whiteAlpha"))
                        .cornerRadius(12)
                        .padding(8)
                        .padding(.horizontal, 12)
                }
                
                Button {
                    if isAuth {
                        print("Авторизация")
                    } else {
                        print("Регистрация")
                    }
                } label: {
                    Text(isAuth ? "Войти" : "Регистрация")
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
                    isAuth.toggle()
                } label: {
                    Text(isAuth ? "Регистрация" : "Уже есть аккаунт!")
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
            .padding(isAuth ? 30 : 15)
            
        }.frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            Image("login_auth_v4")
                .ignoresSafeArea()
                .blur(radius: isAuth ? 0 : 5)
        )
        .animation(Animation.easeOut(duration: 0.3), value: isAuth)
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
