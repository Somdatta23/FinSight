import SwiftUI
import Combine

struct DailyAmount: Identifiable {
    let id = UUID()
    let date: Date
    let amount: Double
    let dayLabel: String
}

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var transactions: [Transaction] = []
    @Published var dailyBreakdown: [DailyAmount] = []
    @Published var isLoading: Bool = true

    let category: TransactionCategory

    var totalSpending: Double {
        transactions.reduce(0.0) { $0 + $1.amount }
    }

    var transactionCount: Int {
        transactions.count
    }

    var averageTransaction: Double {
        guard !transactions.isEmpty else { return 0 }
        return totalSpending / Double(transactions.count)
    }

    private let persistence: PersistenceService = PersistenceService.shared
    private var cancellables: Set<AnyCancellable> = []

    init(category: TransactionCategory) {
        self.category = category

        persistence.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (allTransactions: [Transaction]) in
                guard let self = self else { return }
                self.transactions = allTransactions.filter { $0.transactionCategory == self.category }
                self.computeDailyBreakdown()
                self.isLoading = false
            }
            .store(in: &cancellables)
            
        persistence.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
    }

    func loadData() {
        isLoading = true
        persistence.loadTransactions()
    }

    func deleteTransaction(at offsets: IndexSet) {
        for index in offsets {
            let t = transactions[index]
            persistence.deleteTransaction(id: t.id.uuidString)
        }
    }

    private func computeDailyBreakdown() {
        let calendar: Calendar = Calendar.current
        var dailyTotals: [Date: Double] = [:]

        let dates = Set(transactions.map { calendar.startOfDay(for: $0.date) }).sorted().suffix(7)

        for date in dates {
            dailyTotals[date] = 0
        }

        for t in transactions {
            let day: Date = calendar.startOfDay(for: t.date)
            dailyTotals[day, default: 0] += t.amount
        }

        let formatter: DateFormatter = DateFormatter()
        formatter.dateFormat = "EEE"

        dailyBreakdown = dailyTotals.map { (date: Date, amount: Double) in
            DailyAmount(date: date, amount: amount, dayLabel: formatter.string(from: date))
        }.sorted { $0.date < $1.date }
    }
}
