//
//  ShimmerModifier.swift
//  AsiaShop
//
//  Shimmer-эффект по статье: https://habr.com/ru/articles/934756/
//  TimelineView вместо @State — стабильная анимация без прыжков ScrollView.
//

import SwiftUI

// MARK: - ShimmeringModifier (TimelineView)

struct ShimmeringModifier: ViewModifier {
    func body(content: Content) -> some View {
        TimelineView(.animation) { timeline in
            let phase = CGFloat(
                timeline.date.timeIntervalSinceReferenceDate
                    .truncatingRemainder(dividingBy: 1)
            )
            content.modifier(AnimatedShimmerMask(phase: phase))
        }
    }
}

// MARK: - AnimatedShimmerMask

struct AnimatedShimmerMask: AnimatableModifier {
    var phase: CGFloat

    var animatableData: CGFloat {
        get { phase }
        set { phase = newValue }
    }

    func body(content: Content) -> some View {
        content.mask(ShimmerGradientMask(phase: phase).scaleEffect(3))
    }
}

// MARK: - ShimmerGradientMask

struct ShimmerGradientMask: View {
    let phase: CGFloat

    var body: some View {
        GeometryReader { geo in
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .white.opacity(0.1), location: phase),
                    .init(color: .white.opacity(0.6), location: phase + 0.1),
                    .init(color: .white.opacity(0.1), location: phase + 0.2),
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
            .rotationEffect(.degrees(-45))
            .offset(x: -geo.size.width, y: -geo.size.height)
            .frame(width: geo.size.width * 3, height: geo.size.height * 3)
        }
    }
}

// MARK: - View extension

extension View {
    func shimmering() -> some View {
        modifier(ShimmeringModifier())
    }
}

// MARK: - ShimmerRectangle

/// Прямоугольник-заглушка с shimmer для skeleton.
struct ShimmerRectangle: View {
    let width: CGFloat?
    let height: CGFloat
    let cornerRadius: CGFloat

    init(width: CGFloat? = nil, height: CGFloat = 12, cornerRadius: CGFloat = 8) {
        self.width = width
        self.height = height
        self.cornerRadius = cornerRadius
    }

    var body: some View {
        RoundedRectangle(cornerRadius: cornerRadius)
            .fill(Color.gray.opacity(0.3))
            .frame(width: width, height: height)
            .shimmering()
    }
}
