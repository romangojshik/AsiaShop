//
//  CatalogSetRowShimmerView.swift
//  AsiaShop
//
//  Skeleton для CatalogSetRowView.
//

import SwiftUI

struct CatalogSetRowShimmerView: View {
    private enum Constants {
        static let setWidth: CGFloat = 110
    }

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Padding.padding6) {
            ShimmerRectangle(width: Constants.setWidth, height: Constants.setWidth, cornerRadius: AppConstants.Padding.padding18)

            VStack(alignment: .leading, spacing: AppConstants.Padding.padding6) {
                ShimmerRectangle(width: 50, height: 14, cornerRadius: 6)
                ShimmerRectangle(width: 90, height: 14, cornerRadius: 6)
                ShimmerRectangle(width: 40, height: 12, cornerRadius: 6)
            }
            .padding(.horizontal, AppConstants.Padding.padding8)
        }
        .frame(width: Constants.setWidth, alignment: .leading)
    }
}
