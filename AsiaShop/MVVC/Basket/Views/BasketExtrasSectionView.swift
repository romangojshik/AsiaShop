//
//  BasketExtrasSectionView.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 7.03.26.
//

import SwiftUI

// MARK: - BasketExtrasSectionView

struct BasketExtrasSectionView: View {
    @EnvironmentObject var storage: OrderDataStorage
    
    private let extrasList: [Extra]
    
    init(extras: [Extra] = Extra.allCases) {
        self.extrasList = extras
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding8) {
            ForEach(extrasList, id: \.self) { extra in
                BasketExtraRowView(extra: extra)
            }
        }
        .padding(.horizontal)
        .padding(.vertical, AppConstants.Padding.padding12)
    }
}
