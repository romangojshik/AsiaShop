//
//  ProductDetailView.swift
//  AsiaShop
//
//  Created by Roman on 11/21/23.
//

import SwiftUI

struct ProductDetailView: View {
    
    var viewModel: ProductDetailViewModel
    @State var size = "6 штук"
    @State var count = 1
    
    @Environment(\.presentationMode) var presentationMode
        
    var body: some View {
        
        VStack {
            VStack(alignment: .leading) {
                Image("nori")
                    .resizable()
//                    .aspectRatio(contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: 300)
                HStack {
                    Text("\(viewModel.product.title)")
                        .font(.title2).bold()
                    Spacer()
                    Text(String(format: "%.2f", viewModel.getPrice(size: size)) + " руб")
                        .font(.title2)
                }.padding(.horizontal)
                
                Text("\(viewModel.product.description)")
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                
                HStack {
                    Stepper("Количество сетов:", value: $count, in: 1...10)
                        .font(.title3)
                    Text("\(count)")
                        .padding(.leading)
                } .padding(.horizontal)
                
                .padding(.vertical, 20)
                Text("Количество суш в одном сете:")
                    .bold()
                    .padding()
                Picker("Количество суш в одном сете:", selection: $size) {
                    ForEach(viewModel.sizes, id: \.self) { item in
                        Text(item)
                    }
                }.pickerStyle(SegmentedPickerStyle()).foregroundColor(Color.black)
                .padding(.horizontal)
            }
            
            Spacer()
            Spacer()

            Button {
                var position = Position(
                    id: UUID().uuidString,
                    product: viewModel.product,
                    count: count
                )
                position.product.price = viewModel.getPrice(size: size )
                BasketViewModel.shared.addPosition(position: position)
                presentationMode.wrappedValue.dismiss()
            } label: {
                Text("В корзину")
                    .bold()
                    .padding()
                    .padding(.horizontal, 50)
                    .foregroundColor(Color.black)
                    .font(.title3)
                    .background(LinearGradient(gradient: Gradient(colors: [Color("yellow"), Color("orange")]), startPoint: .leading, endPoint: .trailing))
                    .cornerRadius(30)
            }
            Spacer()
        }.ignoresSafeArea()
    }
}

struct ProductDetailView_Previews: PreviewProvider {
    static var previews: some View {
        ProductDetailView(viewModel: ProductDetailViewModel(product: Product(
            id: "3",
            title: "Нори",
            imageURL: "String",
            price: 17.5,
            description: "Японское название различных съедобных видов красных водорослей из рода Порфира (Porphyra), включая, в первую очередь, виды Porphyra tenera Kjellm. и Porphyra yezoensis Ueda."
        )))
    }
}
