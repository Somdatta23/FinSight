import Foundation
import Combine
import SwiftUI
import FirebaseAuth

@MainActor
class AuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var fullName = ""
    
    @Published var authError: String?
    @Published var isLoading = false
    @Published var didAuthenticate = false
    @Published var resetEmailSent = false
    
    private let authService = AuthService.shared
    private var cancellables = Set<AnyCancellable>()
    
    var isEmailValid: Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    init() {
        // Initialize with current user data if available
        if let user = authService.currentUser {
            self.email = user.email ?? ""
            self.fullName = user.displayName ?? ""
            self.didAuthenticate = true
        }

        authService.$authError
            .receive(on: DispatchQueue.main)
            .assign(to: &$authError)
            
        authService.$isLoading
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
            
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
    }
    
    var isSignInValid: Bool {
        !email.isEmpty && !password.isEmpty
    }
    
    var isSignUpValid: Bool {
        !email.isEmpty && password.count >= 6 && password == confirmPassword
    }
    
    func signIn() {
        authService.signIn(email: email, password: password) { [weak self] success in
            if success {
                self?.didAuthenticate = true
            }
        }
    }
    
    func signUp() {
        authService.signUp(email: email, password: password, fullName: fullName) { [weak self] success in
            if success {
                self?.didAuthenticate = true
            }
        }
    }
    
    func resetPassword() {
        guard isEmailValid else {
            authError = "Please enter a valid email address."
            return
        }
        authError = nil
        resetEmailSent = false
        authService.resetPassword(email: email) { [weak self] success in
            DispatchQueue.main.async {
                if success {
                    self?.resetEmailSent = true
                }
            }
        }
    }
    
    func signOut() {
        authService.signOut()
    }
    
    func clearErrors() {
        authError = nil
    }
}
