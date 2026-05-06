import SwiftUI

struct CategoriesView: View {
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
                } else if sharedViewModel.categorySummaries.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "square.grid.2x2")
                            .font(.system(size: 48))
                            .foregroundStyle(.white.opacity(0.3))
                        Text("No categories yet")
                            .font(.headline)
                            .foregroundStyle(.white.opacity(0.5))
                        Text("Add transactions to see category breakdown.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.35))
                    }
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 14) {
                            ForEach(Array(sharedViewModel.categorySummaries.enumerated()), id: \.element.id) { index, item in
                                NavigationLink(destination: CategoryDetailView(category: item.category)) {
                                    CategoryRowView(item: item, delay: Double(index) * 0.08)
                                }
                                .buttonStyle(RowButtonStyle())
                            }
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Categories")
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

struct CategoryRowView: View {
    let item: CategorySpending
    let delay: Double
    @State private var isVisible: Bool = false

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: item.category.iconName)
                .font(.title3)
                .foregroundStyle(item.category.color)
                .frame(width: 44, height: 44)
                .background(item.category.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 13))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.category.displayName)
                    .font(.headline)
                    .foregroundStyle(.white)
                Text("\(item.count) transactions")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 4) {
                Text(String(format: "₹%.0f", item.total))
                    .font(.headline)
                    .foregroundStyle(.white)
                Text(String(format: "%.0f%%", item.percentage))
                    .font(.caption.weight(.medium))
                    .foregroundStyle(item.category.color)
            }

            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding(18)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 20))
        .offset(x: isVisible ? 0 : 30)
        .opacity(isVisible ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.45, dampingFraction: 0.8).delay(delay)) {
                isVisible = true
            }
        }
    }
}

struct RowButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2), value: configuration.isPressed)
    }
}

