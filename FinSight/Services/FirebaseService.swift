import Foundation
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth
import Combine

class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    private let auth = Auth.auth()
    
    @Published var transactions: [Transaction] = []
    @Published var isLoading = false
    @Published var currentUser: User?
    @Published var lastError: String?
    
    private var listenerRegistration: ListenerRegistration?
    
    private init() {
        self.currentUser = auth.currentUser
    }
    
    // MARK: - Authentication Helper
    private var transactionsCollection: CollectionReference? {
        guard let uid = AuthService.shared.currentUser?.uid else { return nil }
        return db.collection("users").document(uid).collection("transactions")
    }
    
    // MARK: - Authentication
    func ensureAuthenticated() async throws {
        if let user = auth.currentUser {
            self.currentUser = user
            return
        }
        
        do {
            let result = try await auth.signInAnonymously()
            self.currentUser = result.user
            print("Signed in anonymously: \(result.user.uid)")
        } catch {
            self.lastError = "Auth failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    // MARK: - Firestore Operations
    func startListeningForTransactions() {
        guard let collection = transactionsCollection else { return }
        
        isLoading = true
        lastError = nil
        listenerRegistration?.remove()
        
        listenerRegistration = collection
            .order(by: "date", descending: true)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.lastError = "Sync error: \(error.localizedDescription)"
                    print("Error listening for transactions: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = snapshot?.documents else { return }
                
                self.transactions = documents.compactMap { doc -> Transaction? in
                    let data = doc.data()
                    return self.mapDataToTransaction(data)
                }
            }
    }
    
    func fetchTransactions(completion: @escaping ([Transaction]) -> Void) {
        guard let collection = transactionsCollection else {
            completion([])
            return
        }
        
        collection.order(by: "date", descending: true).getDocuments { [weak self] snapshot, error in
            guard let self = self, let documents = snapshot?.documents else {
                print("Error fetching transactions: \(error?.localizedDescription ?? "Unknown error")")
                completion([])
                return
            }
            
            let transactions: [Transaction] = documents.compactMap { doc in
                self.mapDataToTransaction(doc.data())
            }
            completion(transactions)
        }
    }
    
    func saveTransaction(_ transaction: Transaction) async throws {
        guard let collection = transactionsCollection else { 
            let error = NSError(domain: "Auth", code: 401, userInfo: [NSLocalizedDescriptionKey: "No user authenticated"])
            self.lastError = error.localizedDescription
            throw error 
        }
        
        do {
            let data = mapTransactionToData(transaction)
            try await collection
                .document(transaction.id.uuidString)
                .setData(data)
        } catch {
            self.lastError = "Save failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    func deleteTransaction(id: String) async throws {
        guard let collection = transactionsCollection else { return }
        
        do {
            try await collection.document(id).delete()
        } catch {
            self.lastError = "Delete failed: \(error.localizedDescription)"
            throw error
        }
    }
    
    func updateTransaction(_ transaction: Transaction) async throws {
        guard let collection = transactionsCollection else { return }
        let data = mapTransactionToData(transaction)
        try await collection
            .document(transaction.id.uuidString)
            .setData(data)
    }
    
    // MARK: - Helpers
    private func mapTransactionToData(_ t: Transaction) -> [String: Any] {
        return [
            "id": t.id.uuidString,
            "amount": t.amount,
            "category": t.category,
            "merchant": t.merchant,
            "date": Timestamp(date: t.date)
        ]
    }
    
    private func mapDataToTransaction(_ data: [String: Any]) -> Transaction? {
        guard let idString = data["id"] as? String,
              let id = UUID(uuidString: idString),
              let amount = data["amount"] as? Double,
              let category = data["category"] as? String,
              let merchant = data["merchant"] as? String,
              let timestamp = data["date"] as? Timestamp else {
            return nil
        }
        
        return Transaction(
            id: id,
            amount: amount,
            category: category,
            merchant: merchant,
            date: timestamp.dateValue()
        )
    }
}
