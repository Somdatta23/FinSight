import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var sharedViewModel: TransactionViewModel
    @State private var showAddTransaction: Bool = false

    private var addTransactionButton: some View {
        Button {
            showAddTransaction = true
        } label: {
            Image(systemName: "plus.circle.fill")
                .font(.title3.weight(.bold))
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
        }
        .buttonStyle(ScaleButtonStyle())
    }

    struct ScaleButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.05, blue: 0.18),
                        Color(red: 0.05, green: 0.03, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if sharedViewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if sharedViewModel.insights.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "lightbulb.slash")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("No insights available")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Add more transactions to generate spending insights.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.35))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 16) {
                            ForEach(Array(sharedViewModel.insights.enumerated()), id: \.element.id) { index, insight in
                                InsightFullCardView(insight: insight, delay: Double(index) * 0.1)
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Insights")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    addTransactionButton
                }
            }
        }
        .sheet(isPresented: $showAddTransaction) {
            AddTransactionView()
                .preferredColorScheme(.dark)
        }
        .onAppear {
            sharedViewModel.refresh()
        }
    }
}

// MARK: - Full Insight Card (for listing)
struct InsightFullCardView: View {
    let insight: Insight
    let delay: Double
    @State private var isVisible: Bool = false

    private var accentColor: Color {
        switch insight.type {
        case .alert: return .red
        case .info: return .blue
        case .warning: return .orange
        case .positive: return .green
        }
    }

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: insight.iconName)
                .font(.title2)
                .foregroundStyle(accentColor)
                .frame(width: 48, height: 48)
                .background(accentColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 14))

            VStack(alignment: .leading, spacing: 8) {
                Text(insight.title)
                    .font(.headline)
                    .foregroundStyle(.white)

                Text(insight.description)
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.7))
                    .fixedSize(horizontal: false, vertical: true)

                Text(insight.type.rawValue.capitalized)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(accentColor)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 4)
                    .background(accentColor.opacity(0.15))
                    .clipShape(Capsule())
            }

            Spacer()
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
        .overlay(
            RoundedRectangle(cornerRadius: 22)
                .stroke(accentColor.opacity(0.2), lineWidth: 1)
        )
        .offset(y: isVisible ? 0 : 20)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}
