//
//  ScreenContainer.swift
//  AsiaShop
//
//  Created by Roman Gojshik on 3.02.26.
//

import SwiftUI

struct ScreenContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color(white: 0.15).ignoresSafeArea()
            
            VStack(spacing: 0) {
                content
            }
            
            .background(Color.white)
            .cornerRadius(16)
            .padding(.horizontal, 6)
            .padding(.vertical, 6)
        }
    }
}
