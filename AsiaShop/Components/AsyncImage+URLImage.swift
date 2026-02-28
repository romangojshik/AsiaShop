//
//  AsyncImage+URLImage.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 01.03.26.
//

import SwiftUI

/// Загружает изображение по URL с placeholder'ом и индикатором загрузки.
struct URLImageView: View {
    let urlString: String
    var loadingTint: Color = .gray
    var failurePlaceholder: Color = Color.gray.opacity(0.1)

    var body: some View {
        AsyncImage(url: URL(string: urlString)) { phase in
            switch phase {
            case .empty:
                ZStack {
                    failurePlaceholder
                    ProgressView()
                        .tint(loadingTint)
                }
            case .success(let image):
                image
                    .resizable()
                    .scaledToFill()
            case .failure:
                Image(Constants.Images.placeholderSushi)
                    .resizable()
                    .scaledToFill()
            @unknown default:
                failurePlaceholder
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
