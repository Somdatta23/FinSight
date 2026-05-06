import SwiftUI

struct Transaction: Codable, Identifiable, Sendable {
    let id: UUID
    let amount: Double
    let category: String
    let merchant: String
    let date: Date

    var transactionCategory: TransactionCategory {
        TransactionCategory(rawValue: category) ?? .other
    }

    var hour: Int {
        Calendar.current.component(.hour, from: date)
    }

    var isWeekend: Bool {
        Calendar.current.isDateInWeekend(date)
    }

    var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter.string(from: date)
    }

    var shortDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM"
        return formatter.string(from: date)
    }

    var formattedAmount: String {
        String(format: "₹%.0f", amount)
    }

    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
}
