import SwiftUI
import Combine

@MainActor
class AddTransactionViewModel: ObservableObject {
    @Published var amountText: String = ""
    @Published var selectedCategory: TransactionCategory = .food
    @Published var merchant: String = ""
    @Published var date: Date = Date()
    @Published var showValidationError: Bool = false
    @Published var validationMessage: String = ""
    @Published var didSave: Bool = false

    private let persistence: PersistenceService = PersistenceService.shared

    var amount: Double? {
        Double(amountText)
    }

    var isValid: Bool {
        guard let amt = amount, amt > 0 else { return false }
        guard !merchant.trimmingCharacters(in: .whitespaces).isEmpty else { return false }
        return true
    }

    func save() {
        // Validate amount
        guard let amt = amount, amt > 0 else {
            validationMessage = "Please enter a valid amount greater than 0."
            showValidationError = true
            return
        }

        // Validate merchant
        let trimmedMerchant: String = merchant.trimmingCharacters(in: .whitespaces)
        guard !trimmedMerchant.isEmpty else {
            validationMessage = "Please enter a merchant name."
            showValidationError = true
            return
        }

        showValidationError = false
        persistence.saveTransaction(
            amount: amt,
            category: selectedCategory.rawValue,
            merchant: trimmedMerchant,
            date: date
        )

        didSave = true
        resetForm()
    }

    func resetForm() {
        amountText = ""
        selectedCategory = .food
        merchant = ""
        date = Date()
    }
}
