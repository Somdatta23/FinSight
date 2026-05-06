import SwiftUI
import Combine

@MainActor
class InsightViewModel: ObservableObject {
    @Published var insights: [Insight] = []
    @Published var isLoading: Bool = true

    private let persistence: PersistenceService = PersistenceService.shared
    private let insightEngine: InsightEngine = InsightEngine()
    private var cancellables: Set<AnyCancellable> = []

    init() {
        persistence.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] transactions in
                guard let self = self else { return }
                self.insights = self.insightEngine.generateInsights(from: transactions)
                self.isLoading = false
            }
            .store(in: &cancellables)
            
        persistence.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
    }

    func loadInsights() {
        isLoading = true
        persistence.loadTransactions()
    }
}
