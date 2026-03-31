//
//  AsyncImage+URLImage.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01.03.26.
//

import SwiftUI
import NukeUI


struct URLImageView: View {
    let urlString: String
    var loadingTint: Color = .gray
    var failurePlaceholder: Color = Color.gray.opacity(0.1)

    var body: some View {
        LazyImage(url: URL(string: urlString)) { state in
            if let image = state.image {
                image
                    .resizable()
                    .scaledToFill()
            } else if state.isLoading {
                ZStack {
                    failurePlaceholder
                    ProgressView()
                        .tint(loadingTint)
                }
            } else {
                Image(Constants.Images.placeholderSushi)
                    .resizable()
                    .scaledToFill()
            }
        }
    }
}

// MARK: - Constants
private enum Constants {
    enum Images {
        static let placeholderSushi = "placeholder_sushi"
    }
}
