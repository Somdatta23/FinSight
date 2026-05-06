import SwiftUI

struct RootView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @StateObject private var authService = AuthService.shared
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        Group {
            if !hasCompletedOnboarding {
                OnboardingView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else if authService.currentUser == nil {
                LoginView()
                    .transition(.asymmetric(insertion: .move(edge: .trailing), removal: .move(edge: .leading)))
            } else {
                MainTabView()
                    .environmentObject(transactionViewModel)
                    .transition(.opacity)
                    .onAppear {
                        // Refresh data for the newly authenticated user
                        transactionViewModel.refresh()
                    }
            }
        }
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: hasCompletedOnboarding)
        .animation(.spring(response: 0.5, dampingFraction: 0.8), value: authService.currentUser)
    }
}
