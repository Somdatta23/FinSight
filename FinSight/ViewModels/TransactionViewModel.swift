import SwiftUI
import Combine

struct CategorySpending: Identifiable {
    let id = UUID()
    let category: TransactionCategory
    let total: Double
    let percentage: Double
    let count: Int
}

struct DailySpending: Identifiable {
    let id = UUID()
    let date: Date
    let total: Double
    let dayLabel: String
}

@MainActor
class TransactionViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var totalSpending: Double = 0
    @Published var categorySummaries: [CategorySpending] = []
    @Published var dailySpending: [DailySpending] = []
    @Published var insights: [Insight] = []
    @Published var lastError: String? = nil

    var averageSpending: Double {
        guard !transactions.isEmpty else { return 0 }
        return totalSpending / Double(transactions.count)
    }

    var hasData: Bool {
        !transactions.isEmpty
    }

    private let persistence = PersistenceService.shared
    private let insightEngine = InsightEngine()
    private var cancellables = Set<AnyCancellable>()

    init() {
        // Subscribe to PersistenceService (Core Data + Firestore)
        persistence.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTransactions in
                guard let self = self else { return }
                self.transactions = newTransactions
                self.recomputeSummaries()
            }
            .store(in: &cancellables)

        persistence.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)

        persistence.$lastError
            .receive(on: DispatchQueue.main)
            .assign(to: &$lastError)
    }

    func refresh() {
        persistence.loadTransactions()
    }

    func filteredTransactions(for category: TransactionCategory) -> [Transaction] {
        transactions.filter { $0.transactionCategory == category }
    }

    func totalSpending(for category: TransactionCategory) -> Double {
        filteredTransactions(for: category).reduce(0.0) { $0 + $1.amount }
    }

    func averageSpending(for category: TransactionCategory) -> Double {
        let filtered = filteredTransactions(for: category)
        guard !filtered.isEmpty else { return 0 }
        return totalSpending(for: category) / Double(filtered.count)
    }

    func deleteTransaction(id: UUID) {
        persistence.deleteTransaction(id: id.uuidString)
    }

    private func recomputeSummaries() {
        // Total Spending
        self.totalSpending = transactions.reduce(0.0) { $0 + $1.amount }

        // Category Breakdown
        var catTotals: [TransactionCategory: (amount: Double, count: Int)] = [:]
        for t in transactions {
            let cat = t.transactionCategory
            let current = catTotals[cat, default: (0.0, 0)]
            catTotals[cat] = (current.amount + t.amount, current.count + 1)
        }

        self.categorySummaries = catTotals.map { (cat, data) in
            CategorySpending(
                category: cat,
                total: data.amount,
                percentage: totalSpending > 0 ? (data.amount / totalSpending) * 100.0 : 0,
                count: data.count
            )
        }.sorted { $0.total > $1.total }

        // Daily Breakdown
        var dayTotals: [Date: Double] = [:]
        let calendar = Calendar.current
        for t in transactions {
            let day = calendar.startOfDay(for: t.date)
            dayTotals[day, default: 0] += t.amount
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        self.dailySpending = dayTotals.map { (date, total) in
            DailySpending(date: date, total: total, dayLabel: formatter.string(from: date))
        }.sorted { $0.date < $1.date }

        // Insights
        self.insights = insightEngine.generateInsights(from: transactions)
    }
}
