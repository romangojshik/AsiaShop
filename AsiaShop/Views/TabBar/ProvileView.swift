//
//  ProvileView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct ProvileView: View {
    @State var isAvatarAlertPresented = false
    
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
                Text("Выйти")
            } label: {
                Text("Выйти")
                    .padding()
                    .padding(.horizontal)
                    .background(Color.red)
                    .foregroundColor(Color.white)
                    .cornerRadius(20)
            }.padding()
        }
    }
}

struct ProvileView_Previews: PreviewProvider {
    static var previews: some View {
        ProvileView()
    }
}
