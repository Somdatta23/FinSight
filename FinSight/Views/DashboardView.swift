import SwiftUI
import Charts

struct DashboardView: View {
    @EnvironmentObject private var viewModel: TransactionViewModel
    @State private var showTotalCard: Bool = false
    @State private var animateCharts: Bool = false
    @State private var showAddTransaction: Bool = false

    // Local model for category spending used by the donut chart
    struct CategorySpendingItem: Identifiable {
        let id = UUID()
        let category: TransactionCategory
        let total: Double
        let percentage: Double
    }

    // Compute category spending locally to avoid accessing a missing dynamic member on the environment object
    private var categorySpending: [CategorySpendingItem] {
        // Map each transaction's raw category String to TransactionCategory (fallback to .other if needed), then group and sum
        let categorized = viewModel.transactions.compactMap { txn -> (TransactionCategory, Double)? in
            // Attempt to initialize TransactionCategory from a raw value; adjust initializer if your enum differs
            if let cat = TransactionCategory(rawValue: txn.category) {
                return (cat, txn.amount)
            } else {
                // Fallback: if you have a specific unknown/other case, use it; otherwise skip unknown categories
                #if compiler(>=5.9)
                if let otherCase = (TransactionCategory.self as? Any.Type) {
                    // Placeholder to silence unused code path; we will default to a generic `.other` if it exists
                }
                #endif
                return (TransactionCategory.other, txn.amount)
            }
        }

        let totalsByCategory: [TransactionCategory: Double] = Dictionary(grouping: categorized, by: { $0.0 })
            .mapValues { group in
                group.reduce(0) { $0 + $1.1 }
            }

        let grandTotal = totalsByCategory.values.reduce(0, +)

        // Avoid division by zero
        guard grandTotal > 0 else {
            return totalsByCategory.map { (category, total) in
                CategorySpendingItem(category: category, total: total, percentage: 0)
            }
            .sorted { $0.total > $1.total }
        }

        return totalsByCategory.map { (category, total) in
            CategorySpendingItem(category: category, total: total, percentage: (total / grandTotal) * 100)
        }
        .sorted { $0.total > $1.total }
    }

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
                // Background gradient
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.05, blue: 0.18),
                        Color(red: 0.05, green: 0.03, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                if viewModel.isLoading {
                    ProgressView()
                        .tint(.white)
                        .scaleEffect(1.5)
                } else if !viewModel.hasData {
                    emptyStateView
                } else {
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            totalSpendingCard
                            insightsSection
                            categoryDonutChart
                            weeklyTrendChart
                            recentTransactions
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 100)
                    }
                }
            }
            .navigationTitle("Dashboard")
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
            viewModel.refresh()
            withAnimation(.easeOut(duration: 0.6)) {
                showTotalCard = true
            }
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                animateCharts = true
            }
        }
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "tray.fill")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.2))

            Text("No transactions yet")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white.opacity(0.6))

            Text("Add your first entry using the + button below.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.4))
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    // MARK: - Total Spending Card
    private var totalSpendingCard: some View {
        VStack(spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 6) {
                    Text("Total Spending")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.7))

                    Text(String(format: "₹%.0f", viewModel.totalSpending))
                        .font(.system(size: 38, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 6) {
                    Text("\(viewModel.transactions.count) transactions")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.6))

                    Text(String(format: "Avg ₹%.0f", viewModel.averageSpending))
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.white.opacity(0.8))
                }
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.25, blue: 0.95),
                    Color(red: 0.35, green: 0.2, blue: 0.85),
                    Color(red: 0.25, green: 0.35, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color(red: 0.45, green: 0.25, blue: 0.95).opacity(0.4), radius: 20, y: 10)
        .scaleEffect(showTotalCard ? 1 : 0.9)
        .opacity(showTotalCard ? 1 : 0)
    }

    // MARK: - Insights Horizontal Scroll
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Insights")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            if viewModel.insights.isEmpty {
                Text("No insights to show yet.")
                    .font(.subheadline)
                    .foregroundStyle(.white.opacity(0.5))
            } else {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 14) {
                        ForEach(viewModel.insights) { insight in
                            InsightCardView(insight: insight)
                        }
                    }
                    .padding(.vertical, 4)
                }
            }
        }
    }

    // MARK: - Donut Chart
    private var categoryDonutChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Breakdown")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            HStack(spacing: 20) {
                Chart(categorySpending) { item in
                    SectorMark(
                        angle: .value("Amount", animateCharts ? item.total : 0),
                        innerRadius: .ratio(0.6),
                        angularInset: 2
                    )
                    .foregroundStyle(item.category.color)
                    .cornerRadius(6)
                }
                .frame(width: 140, height: 140)

                VStack(alignment: .leading, spacing: 8) {
                    ForEach(categorySpending) { item in
                        HStack(spacing: 8) {
                            Circle()
                                .fill(item.category.color)
                                .frame(width: 10, height: 10)
                            Text(item.category.displayName)
                                .font(.caption)
                                .foregroundStyle(.white.opacity(0.8))
                            Spacer()
                            Text(String(format: "%.0f%%", item.percentage))
                                .font(.caption.weight(.semibold))
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Weekly Trend Line Chart
    private var weeklyTrendChart: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Weekly Trend")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            Chart(viewModel.dailySpending) { item in
                LineMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Amount", animateCharts ? item.total : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.55, green: 0.25, blue: 0.95), Color(red: 0.35, green: 0.65, blue: 1.0)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .lineStyle(StrokeStyle(lineWidth: 3, lineCap: .round))
                .interpolationMethod(.catmullRom)

                AreaMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Amount", animateCharts ? item.total : 0)
                )
                .foregroundStyle(
                    LinearGradient(
                        colors: [Color(red: 0.55, green: 0.25, blue: 0.95).opacity(0.3), .clear],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                )
                .interpolationMethod(.catmullRom)

                PointMark(
                    x: .value("Day", item.dayLabel),
                    y: .value("Amount", animateCharts ? item.total : 0)
                )
                .foregroundStyle(.white)
                .symbolSize(30)
            }
            .chartYAxis {
                AxisMarks(position: .leading) { _ in
                    AxisGridLine()
                        .foregroundStyle(.white.opacity(0.1))
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(.white.opacity(0.6))
                }
            }
            .frame(height: 200)
            .padding(20)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }

    // MARK: - Recent Transactions
    private var recentTransactions: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Recent Transactions")
                .font(.title3.weight(.semibold))
                .foregroundStyle(.white)

            VStack(spacing: 4) {
                ForEach(viewModel.transactions.prefix(8)) { transaction in
                    TransactionRowView(transaction: transaction)
                    if transaction.id != viewModel.transactions.prefix(8).last?.id {
                        Divider()
                            .background(.white.opacity(0.1))
                    }
                }
            }
            .padding(16)
            .background(.ultraThinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 20))
        }
    }
}

