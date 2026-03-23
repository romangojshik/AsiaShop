//
//  SushiRowShimmerView.swift
//  AsiaShop
//
//  Skeleton для SushiRowView.
//

import SwiftUI

struct RollRowShimmerView: View {
    private enum Constants {
        static let imageSize: CGFloat = 96
        static let cornerRadius: CGFloat = 16
    }

    var body: some View {
        HStack(spacing: AppConstants.Padding.padding16) {
            ShimmerRectangle(width: Constants.imageSize, height: Constants.imageSize, cornerRadius: AppConstants.Padding.padding16)

            VStack(alignment: .leading, spacing: AppConstants.Padding.padding8) {
                ShimmerRectangle(width: 120, height: 18, cornerRadius: 6)
                ShimmerRectangle(width: 80, height: 14, cornerRadius: 6)
                ShimmerRectangle(width: 60, height: 14, cornerRadius: 6)
            }

            Spacer()
        }
        .padding(.horizontal)
    }
}
