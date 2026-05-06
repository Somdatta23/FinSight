import SwiftUI
import Combine

@MainActor
class DashboardViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var insights: [Insight] = []
    @Published var categorySpending: [CategorySpending] = []
    @Published var dailySpending: [DailySpending] = []
    @Published var isLoading: Bool = true
    @Published var errorMessage: String? = nil

    func getTransactions(for categoryName: String) -> [Transaction] {
        transactions.filter { $0.category == categoryName }
    }

    var totalSpending: Double {
        transactions.reduce(0.0) { $0 + $1.amount }
    }

    var transactionCount: Int {
        transactions.count
    }

    var averageSpending: Double {
        guard !transactions.isEmpty else { return 0 }
        return totalSpending / Double(transactions.count)
    }

    var hasData: Bool {
        !transactions.isEmpty
    }

    private let persistence: PersistenceService = PersistenceService.shared
    private let insightEngine: InsightEngine = InsightEngine()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        // Subscribe to PersistenceService changes for auto-refresh
        persistence.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newTransactions in
                guard let self = self else { return }
                self.transactions = newTransactions
                self.computeCategorySpending()
                self.computeDailySpending()
                self.insights = self.insightEngine.generateInsights(from: newTransactions)
                self.isLoading = false
            }
            .store(in: &cancellables)
        persistence.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
    }

    func loadData() {
        isLoading = true
        errorMessage = nil
        persistence.seedMockDataIfNeeded()
        persistence.loadTransactions()
    }

    func refresh() {
        persistence.loadTransactions()
    }

    private func computeCategorySpending() {
        var totals: [TransactionCategory: (amount: Double, count: Int)] = [:]
        for t in transactions {
            let cat: TransactionCategory = t.transactionCategory
            let current = totals[cat, default: (0.0, 0)]
            totals[cat] = (current.amount + t.amount, current.count + 1)
        }

        let total: Double = totalSpending
        categorySpending = totals.map { (cat: TransactionCategory, data: (amount: Double, count: Int)) in
            CategorySpending(
                category: cat,
                total: data.amount,
                percentage: total > 0 ? (data.amount / total) * 100.0 : 0,
                count: data.count
            )
        }.sorted { $0.total > $1.total }
    }

    private func computeDailySpending() {
        var dailyTotals: [Date: Double] = [:]
        let calendar: Calendar = Calendar.current

        for t in transactions {
            let day: Date = calendar.startOfDay(for: t.date)
            dailyTotals[day, default: 0] += t.amount
        }

        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "EEE"

        dailySpending = dailyTotals.map { (date: Date, total: Double) in
            DailySpending(date: date, total: total, dayLabel: formatter.string(from: date))
        }.sorted { $0.date < $1.date }
    }
}
