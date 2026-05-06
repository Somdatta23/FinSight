import SwiftUI

struct InsightEngine: Sendable {

    /// Generates all behavioral insights from the transaction list.
    func generateInsights(from transactions: [Transaction]) -> [Insight] {
        var insights: [Insight] = []

        if let insight = checkLateNightSpending(transactions) {
            insights.append(insight)
        }
        if let insight = checkWeekendSpendingSpike(transactions) {
            insights.append(insight)
        }
        insights.append(contentsOf: checkCategoryDominance(transactions))
        if let insight = checkTopMerchant(transactions) {
            insights.append(insight)
        }
        if let insight = checkHighSingleTransaction(transactions) {
            insights.append(insight)
        }

        return insights
    }

    // MARK: - Rule: Late Night Spending
    /// If >30% of food spending occurs after 21:00 → "Late Night Spending"
    private func checkLateNightSpending(_ transactions: [Transaction]) -> Insight? {
        let foodTransactions = transactions.filter { $0.transactionCategory == .food }
        guard !foodTransactions.isEmpty else { return nil }

        let lateNightFood = foodTransactions.filter { $0.hour >= 21 }
        let lateNightTotal = lateNightFood.reduce(0.0) { $0 + $1.amount }
        let foodTotal = foodTransactions.reduce(0.0) { $0 + $1.amount }
        let percentage = (lateNightTotal / foodTotal) * 100.0

        guard percentage > 30 else { return nil }

        return Insight(
            id: "late_night_spending",
            title: "Late Night Spending",
            description: String(format: "%.0f%% of your food spending (₹%.0f) happens after 9 PM. Consider planning meals earlier to save.", percentage, lateNightTotal),
            iconName: "moon.stars.fill",
            type: .warning
        )
    }

    // MARK: - Rule: Weekend Spending Spike
    /// If weekend average spend > weekday average → "Weekend Spending Spike"
    private func checkWeekendSpendingSpike(_ transactions: [Transaction]) -> Insight? {
        let weekendTransactions = transactions.filter { $0.isWeekend }
        let weekdayTransactions = transactions.filter { !$0.isWeekend }

        guard !weekendTransactions.isEmpty, !weekdayTransactions.isEmpty else { return nil }

        let weekendTotal = weekendTransactions.reduce(0.0) { $0 + $1.amount }
        let weekdayTotal = weekdayTransactions.reduce(0.0) { $0 + $1.amount }

        let weekendDays = Set(weekendTransactions.map { Calendar.current.startOfDay(for: $0.date) }).count
        let weekdayDays = Set(weekdayTransactions.map { Calendar.current.startOfDay(for: $0.date) }).count

        let weekendAvg = weekendTotal / Double(max(weekendDays, 1))
        let weekdayAvg = weekdayTotal / Double(max(weekdayDays, 1))

        guard weekendAvg > weekdayAvg else { return nil }

        let spikePercent = ((weekendAvg - weekdayAvg) / weekdayAvg) * 100.0

        return Insight(
            id: "weekend_spike",
            title: "Weekend Spending Spike",
            description: String(format: "Your weekend spending averages ₹%.0f/day — %.0f%% higher than weekdays (₹%.0f/day).", weekendAvg, spikePercent, weekdayAvg),
            iconName: "calendar.badge.exclamationmark",
            type: .alert
        )
    }

    // MARK: - Rule: Category Dominance
    /// If one category >40% of total spending → "Category Dominance"
    private func checkCategoryDominance(_ transactions: [Transaction]) -> [Insight] {
        let totalSpending = transactions.reduce(0.0) { $0 + $1.amount }
        guard totalSpending > 0 else { return [] }

        var categoryTotals: [TransactionCategory: Double] = [:]
        for t in transactions {
            categoryTotals[t.transactionCategory, default: 0] += t.amount
        }

        var insights: [Insight] = []
        for (category, total) in categoryTotals {
            let percentage = (total / totalSpending) * 100.0
            if percentage > 40 {
                insights.append(Insight(
                    id: "dominance_\(category.rawValue.lowercased())",
                    title: "\(category.displayName) Dominance",
                    description: String(format: "%@ accounts for %.0f%% of your total spending (₹%.0f). Consider diversifying your budget.", category.displayName, percentage, total),
                    iconName: "chart.pie.fill",
                    type: .info
                ))
            }
        }

        return insights
    }

    // MARK: - Rule: Top Merchant
    /// Identifies the single merchant with the highest aggregate spending.
    private func checkTopMerchant(_ transactions: [Transaction]) -> Insight? {
        var merchantTotals: [String: Double] = [:]
        for t in transactions {
            merchantTotals[t.merchant, default: 0] += t.amount
        }

        guard let top = merchantTotals.max(by: { $0.value < $1.value }) else { return nil }

        let totalSpending = transactions.reduce(0.0) { $0 + $1.amount }
        let percentage = (top.value / totalSpending) * 100.0

        return Insight(
            id: "top_merchant",
            title: "Top Merchant: \(top.key)",
            description: String(format: "You spent ₹%.0f at %@ (%.0f%% of total). This is your most-visited merchant.", top.value, top.key, percentage),
            iconName: "storefront.fill",
            type: .info
        )
    }

    // MARK: - Rule: High Single Transaction
    /// Flags single transactions that are significantly higher than average.
    private func checkHighSingleTransaction(_ transactions: [Transaction]) -> Insight? {
        guard !transactions.isEmpty else { return nil }

        let avg = transactions.reduce(0.0) { $0 + $1.amount } / Double(transactions.count)
        let highTransactions = transactions.filter { $0.amount > avg * 3.0 }

        guard let highest = highTransactions.max(by: { $0.amount < $1.amount }) else { return nil }

        return Insight(
            id: "high_single",
            title: "Unusually Large Transaction",
            description: String(format: "₹%.0f at %@ is %.1fx your average spend (₹%.0f). Watch out for impulse purchases.", highest.amount, highest.merchant, highest.amount / avg, avg),
            iconName: "exclamationmark.triangle.fill",
            type: .alert
        )
    }
}
