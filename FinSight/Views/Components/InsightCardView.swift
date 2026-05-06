import SwiftUI

struct InsightCardView: View {
    let insight: Insight
    @State private var isVisible = false

    private var accentColor: Color {
        switch insight.type {
        case .alert: return .red
        case .info: return .blue
        case .warning: return .orange
        case .positive: return .green
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 10) {
                Image(systemName: insight.iconName)
                    .font(.title2)
                    .foregroundStyle(accentColor)
                    .frame(width: 40, height: 40)
                    .background(accentColor.opacity(0.15))
                    .clipShape(RoundedRectangle(cornerRadius: 10))

                Text(insight.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Spacer()
            }

            Text(insight.description)
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.75))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(18)
        .frame(width: 280)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(accentColor.opacity(0.3), lineWidth: 1)
        )
        .scaleEffect(isVisible ? 1 : 0.92)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                isVisible = true
            }
        }
    }
}
