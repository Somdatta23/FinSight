import SwiftUI
import Charts

struct CategoryDetailView: View {
    @EnvironmentObject private var sharedViewModel: TransactionViewModel
    let category: TransactionCategory
    @State private var animateChart: Bool = false

    var body: some View {
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
            } else if sharedViewModel.filteredTransactions(for: category).isEmpty {
                emptyStateView
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        summarySection
                        
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("\(sharedViewModel.filteredTransactions(for: category).count) Transactions")
                                    .font(.headline)
                                    .foregroundStyle(.white.opacity(0.8))
                                
                                Spacer()
                            }
                            .padding(.horizontal, 4)

                            transactionList
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
        }
        .navigationTitle(category.displayName)
        .navigationBarTitleDisplayMode(.large)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            sharedViewModel.refresh()
        }
    }

    // MARK: - Prominent Summary Section
    private var summarySection: some View {
        VStack(spacing: 8) {
            Text("Total Spent")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.6))
            
            Text(String(format: "₹%.0f", sharedViewModel.totalSpending(for: category)))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            
            HStack(spacing: 20) {
                statIndicator(label: "Average", value: String(format: "₹%.0f/tx", sharedViewModel.averageSpending(for: category)))
            }
            .padding(.top, 4)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 32)
        .background(
            ZStack {
                category.gradient
                
                // Subtle shine effect
                LinearGradient(
                    colors: [.white.opacity(0.12), .clear],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            }
        )
        .clipShape(RoundedRectangle(cornerRadius: 28))
        .shadow(color: category.color.opacity(0.4), radius: 20, y: 10)
    }

    private func statIndicator(label: String, value: String) -> some View {
        HStack(spacing: 6) {
            Text(label + ":")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Text(value)
                .font(.caption.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(.white.opacity(0.1))
        .clipShape(Capsule())
    }

    // MARK: - Transaction List
    private var transactionList: some View {
        let filteredTasks = sharedViewModel.filteredTransactions(for: category)
        return VStack(spacing: 12) {
            ForEach(filteredTasks.indices, id: \.self) { index in
                let transaction = filteredTasks[index]
                transactionRow(transaction)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            withAnimation {
                                sharedViewModel.deleteTransaction(id: transaction.id)
                            }
                        } label: {
                            Label("Delete", systemImage: "trash")
                        }
                    }
                
                if index < filteredTasks.count - 1 {
                    Divider()
                        .background(.white.opacity(0.08))
                        .padding(.leading, 56)
                }
            }
        }
        .padding(16)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    private func transactionRow(_ t: Transaction) -> some View {
        HStack(spacing: 14) {
            Image(systemName: category.iconName)
                .font(.system(size: 14, weight: .bold))
                .foregroundStyle(.white)
                .frame(width: 42, height: 42)
                .background(category.color.opacity(0.3))
                .clipShape(Circle())

            VStack(alignment: .leading, spacing: 4) {
                Text(t.merchant)
                    .font(.body.weight(.semibold))
                    .foregroundStyle(.white)
                
                Text(t.date.formatted(date: .abbreviated, time: .shortened))
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Text(String(format: "₹%.0f", t.amount))
                .font(.body.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 8)
    }

    // MARK: - Empty State
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: category.iconName)
                .font(.system(size: 48))
                .foregroundStyle(category.color.opacity(0.3))

            Text("No transactions available for this category")
                .font(.headline)
                .foregroundStyle(.white.opacity(0.5))

            Text("Add transactions to see your spending here.")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.35))
        }
    }
}
