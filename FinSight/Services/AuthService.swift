import Foundation
import FirebaseAuth
import Combine

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var currentUser: User?
    @Published var isLoading = false
    @Published var authError: String?
    
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // Listen for auth state changes
        Auth.auth().addStateDidChangeListener { [weak self] _, user in
            self?.currentUser = user
            print("Auth state changed: \(user?.email ?? "Signed Out")")
        }
    }
    
    func signUp(email: String, password: String, fullName: String = "", completion: @escaping (Bool) -> Void) {
        isLoading = true
        authError = nil
        
        Auth.auth().createUser(withEmail: email, password: password) { [weak self] result, error in
            if let error = error {
                self?.isLoading = false
                self?.authError = error.localizedDescription
                completion(false)
                return
            }
            
            if !fullName.isEmpty, let user = result?.user {
                let changeRequest = user.createProfileChangeRequest()
                changeRequest.displayName = fullName
                changeRequest.commitChanges { error in
                    self?.isLoading = false
                    if let error = error {
                        print("Error updating profile: \(error.localizedDescription)")
                    }
                    completion(true) // Success even if name update fails
                }
            } else {
                self?.isLoading = false
                completion(true)
            }
        }
    }
    
    func signIn(email: String, password: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        authError = nil
        
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] _, error in
            self?.isLoading = false
            if let error = error {
                self?.authError = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func resetPassword(email: String, completion: @escaping (Bool) -> Void) {
        isLoading = true
        authError = nil
        
        Auth.auth().sendPasswordReset(withEmail: email) { [weak self] error in
            self?.isLoading = false
            if let error = error {
                self?.authError = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func updateDisplayName(_ name: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        let changeRequest = user.createProfileChangeRequest()
        changeRequest.displayName = name
        changeRequest.commitChanges { [weak self] error in
            if let error = error {
                self?.authError = error.localizedDescription
                completion(false)
            } else {
                self?.currentUser = Auth.auth().currentUser
                completion(true)
            }
        }
    }
    
    func updatePassword(newPassword: String, completion: @escaping (Bool) -> Void) {
        guard let user = Auth.auth().currentUser else {
            completion(false)
            return
        }
        
        user.updatePassword(to: newPassword) { [weak self] error in
            if let error = error {
                self?.authError = error.localizedDescription
                completion(false)
            } else {
                completion(true)
            }
        }
    }
    
    func signOut() {
        do {
            try Auth.auth().signOut()
        } catch {
            print("Error signing out: \(error.localizedDescription)")
            self.authError = error.localizedDescription
        }
    }
}
