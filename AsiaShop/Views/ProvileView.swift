//
//  ProvileView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct ProvileView: View {
    @StateObject var viewModel: ProfileViewModel

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
                    TextField(
                        "Ваше имя и фамилия",
                        text: $viewModel.profile.name
                    )
                    .font(.body.bold())
                    
                    HStack {
                        Text("+375")
                        TextField(
                            "Ваш телефон",
                            value: $viewModel.profile.phone,
                            format: .number
                        )
                    }
                }
            }
            
            VStack(alignment: .leading, spacing: 8) {
                Text("Ваш адрес доставки:")
                    .bold()
                TextField("Ваш адрес", text: $viewModel.profile.address)
            }.padding(.horizontal)
            
//            List {
//                if viewModel.orders.count == 0 {
//                    Text("Ваши заказы будут тут!")
//                } else {
//                    ForEach(viewModel.orders, id: \.id) { order in
//                        OrderCell(order: order)
//                    }
//                }
//            }.listStyle(PlainListStyle())
            
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
        .onSubmit{
            viewModel.setProfile()
        }
        .onAppear{
            viewModel.getProfile()
            viewModel.getOrders()
        }
    }
}

struct ProvileView_Previews: PreviewProvider {
    static var previews: some View {
        ProvileView(viewModel: ProfileViewModel(
            profile: .init(
                id: "",
                name: "Test Test",
                phone: +375290000001,
                address: "Брест, сябровская 83"
            )
        ))
    }
}
