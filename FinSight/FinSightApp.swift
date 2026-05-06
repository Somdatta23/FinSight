import SwiftUI
import FirebaseCore

@main
struct FinSightApp: App {
    @State private var showSplash = true
    @StateObject private var transactionViewModel = TransactionViewModel()

    init() {
        FirebaseApp.configure()
        
        // Ensure a fresh start on very first install
        if !UserDefaults.standard.bool(forKey: "hasRunBefore") {
            AuthService.shared.signOut()
            UserDefaults.standard.set(true, forKey: "hasRunBefore")
        }
        
        PersistenceService.shared.loadTransactions()
    }
    
    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashView()
                        .transition(.opacity)
                } else {
                    RootView()
                        .environmentObject(transactionViewModel)
                        .transition(.opacity)
                }
            }
            .preferredColorScheme(.dark)
            .onAppear {
                // Adjust timing based on logo animation duration
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.8) {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showSplash = false
                    }
                }
            }
        }
    }
}
