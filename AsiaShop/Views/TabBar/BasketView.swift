//
//  BasketView.swift
//  AsiaShop
//
//  Created by Roman on 11/19/23.
//

import SwiftUI

struct BasketView: View {
    
    var viewModel: BasketViewModel
    
    var body: some View {
        Text("Корзина!")
    }
}

struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView(viewModel: BasketViewModel())
    }
}
