//
//  ProvileView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct ProvileView: View {
    @State var isAvatarAlertPresented = false
    @State var isQuitAlertPresented = false
    @State var isAuthViewPresented = false
    
    var body: some View {
        VStack(alignment: .center, spacing: 20) {
            HStack(spacing: 16) {
                Image("profile")
                    .resizable()
                    .frame(width: 80, height: 80)
                    .padding(.vertical)
                    .clipShape(Circle())
                    .onTapGesture {
                        isAvatarAlertPresented.toggle()
                    }
                    .confirmationDialog(
                        "Откуда загрузить фотографию",
                        isPresented: $isAvatarAlertPresented) {
                            Button("Из галереи", role: .none) {
                                print("Из галереи")
                            }
                            Button("Сделать фотографию", role: .none) {
                                print("Сделать фотографию")
                            }
                        }
                
                VStack(alignment: .leading, spacing: 12) {
                    Text("Имя Фамилия Отчество")
                        .bold()
                    Text("+375 29 111-11-11")
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Адресс доставки")
                    .bold()
                Text("Бреская область, город Брест")
            }
            
            List {
                Text("Ваши заказы будут тут!")
            }.listStyle(PlainListStyle())
            
            Button {
                isQuitAlertPresented.toggle()
            } label: {
                Text("Выйти")
                    .padding()
                    .padding(.horizontal)
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
            }.padding()
                .confirmationDialog(
                    "Вы хотите выйти?",
                    isPresented: $isQuitAlertPresented
                ) {
                    Button("Выйти", role: .destructive) {
                        isAuthViewPresented.toggle()
                    }
                    Button("Cancel", role: .cancel) {}
                }
            
                .fullScreenCover(isPresented: $isAuthViewPresented, onDismiss: nil) {
                    AuthView()
                }
        }
    }
}

struct ProvileView_Previews: PreviewProvider {
    static var previews: some View {
        ProvileView()
    }
}
