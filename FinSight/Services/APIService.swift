import SwiftUI

final class APIService: Sendable {
    static let shared = APIService()

    private init() {}

    func loadTransactions() async throws -> [Transaction] {
        guard let url = Bundle.main.url(forResource: "mock_transactions", withExtension: "json") else {
            throw APIError.fileNotFound
        }

        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        let transactions = try decoder.decode([Transaction].self, from: data)
        return transactions.sorted { $0.date > $1.date }
    }
}

enum APIError: LocalizedError {
    case fileNotFound
    case decodingFailed

    var errorDescription: String? {
        switch self {
        case .fileNotFound:
            return "Transaction data file not found."
        case .decodingFailed:
            return "Failed to decode transaction data."
        }
    }
}
