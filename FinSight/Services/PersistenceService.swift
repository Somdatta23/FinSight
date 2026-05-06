import Foundation
import SwiftUI
import CoreData
import Combine
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

final class PersistenceService: ObservableObject {
    static let shared: PersistenceService = PersistenceService()

    let container: NSPersistentContainer
    private let firebase = FirebaseService.shared
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()

    @Published var transactions: [Transaction] = []
    @Published var isLoading: Bool = false
    @Published var lastError: String? = nil
    @Published var didAuthenticate: Bool = false
    @Published var email: String = ""
    @Published var fullName: String = ""

    private init() {
        container = NSPersistentContainer(name: "FinSight")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        container.viewContext.automaticallyMergesChangesFromParent = true
        
        // Synchronize with Firebase
        authService.$currentUser
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (user: User?) in
                self?.didAuthenticate = (user != nil)
                if let user = user {
                    self?.email = user.email ?? ""
                    self?.fullName = user.displayName ?? ""
                }
            }
            .store(in: &cancellables)

        firebase.$transactions
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (firebaseTransactions: [Transaction]) in
                self?.transactions = firebaseTransactions
                self?.isLoading = false
                // Optional: Sync back to local Core Data for offline persistent cache
                self?.syncToLocalCache(firebaseTransactions)
            }
            .store(in: &cancellables)
            
        firebase.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
            
        firebase.$lastError
            .receive(on: DispatchQueue.main)
            .assign(to: &$lastError)
    }

    // MARK: - Save Transaction

    func saveTransaction(amount: Double, category: String, merchant: String, date: Date) {
        let newTransaction = Transaction(
            id: UUID(),
            amount: amount,
            category: category,
            merchant: merchant,
            date: date
        )
        
        // Save to Core Data (Local Cache)
        let context = container.viewContext
        let entity = TransactionEntity(context: context)
        entity.id = newTransaction.id
        entity.amount = newTransaction.amount
        entity.category = newTransaction.category
        entity.merchant = newTransaction.merchant
        entity.timestamp = newTransaction.date
        
        do {
            try context.save()
            print("Saved locally to Core Data")
        } catch {
            print("Failed to save to Core Data: \(error.localizedDescription)")
        }
        
        // Save to Firebase (Sync)
        Task {
            do {
                try await firebase.saveTransaction(newTransaction)
            } catch {
                self.lastError = error.localizedDescription
            }
        }
    }

    // MARK: - Fetch Transactions

    func loadTransactions() {
        Task {
            // Only attempt to start listening if we have a user
            // We NO LONGER call firebase.ensureAuthenticated() here as it was 
            // bypassing the LoginView by creating anonymous sessions
            if AuthService.shared.currentUser != nil {
                firebase.startListeningForTransactions()
            } else {
                print("No user authenticated, skipping Firebase listener")
                loadLocalTransactions()
            }
        }
    }
    
    private func loadLocalTransactions() {
        let context = container.viewContext
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \TransactionEntity.timestamp, ascending: false)]
        
        do {
            let entities = try context.fetch(request)
            self.transactions = entities.compactMap { entity -> Transaction? in
                guard let id = entity.id, 
                      let category = entity.category, 
                      let merchant = entity.merchant, 
                      let timestamp = entity.timestamp else { 
                    return nil 
                }
                
                return Transaction(
                    id: id,
                    amount: entity.amount,
                    category: category,
                    merchant: merchant,
                    date: timestamp
                )
            }
        } catch {
            print("Fetch error: \(error.localizedDescription)")
        }
    }

    // MARK: - Delete Transaction

    func deleteTransaction(id transactionId: String) {
        Task {
            do {
                try await firebase.deleteTransaction(id: transactionId)
            } catch {
                self.lastError = error.localizedDescription
            }
        }
        
        let context = container.viewContext
        let request: NSFetchRequest<TransactionEntity> = TransactionEntity.fetchRequest()
        guard let uuid = UUID(uuidString: transactionId) else { return }
        request.predicate = NSPredicate(format: "id == %@", uuid as CVarArg)

        if let results = try? context.fetch(request) {
            for entity in results {
                context.delete(entity)
            }
            try? context.save()
        }
    }
    
    private func syncToLocalCache(_ firebaseTransactions: [Transaction]) {
        // Simple sync strategy for this lite app
        // In production, you'd use a more robust diffing/merging approach
    }

    // MARK: - Seed Mock Data

    func seedMockDataIfNeeded() {
        // Mock data seeding disabled per user request
    }
}
