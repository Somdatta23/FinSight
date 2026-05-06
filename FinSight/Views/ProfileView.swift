import SwiftUI

struct ProfileView: View {
    @StateObject private var viewModel = AuthViewModel()
    @EnvironmentObject var transactionViewModel: TransactionViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Profile Header
                    VStack(spacing: 16) {
                        ZStack {
                            Circle()
                                .fill(LinearGradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)], startPoint: .topLeading, endPoint: .bottomTrailing))
                                .frame(width: 100, height: 100)
                            
                            Text(viewModel.email.prefix(1).uppercased())
                                .font(.system(size: 40, weight: .bold))
                                .foregroundStyle(.white)
                        }
                        
                        Text(viewModel.email)
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        Text("Active Member")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.5))
                    }
                    .padding(.top, 40)
                    
                    // List of Actions
                    VStack(spacing: 0) {
                        NavigationLink(destination: AccountDetailsView()) {
                            ProfileRow(icon: "person.fill", title: "Account Details")
                        }
                        Divider().background(.white.opacity(0.1))
                        
                        NavigationLink(destination: NotificationsView()) {
                            ProfileRow(icon: "bell.fill", title: "Notifications")
                        }
                        Divider().background(.white.opacity(0.1))
                        
                        NavigationLink(destination: SecurityView()) {
                            ProfileRow(icon: "lock.fill", title: "Security")
                        }
                    }
                    .background(.white.opacity(0.05))
                    .clipShape(RoundedRectangle(cornerRadius: 20))
                    .padding(.horizontal, 16)
                    
                    Spacer()
                    
                    // Logout
                    Button {
                        viewModel.signOut()
                    } label: {
                        HStack {
                            Image(systemName: "arrow.right.circle.fill")
                            Text("Log Out")
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.red.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(Color.red.opacity(0.3), lineWidth: 1)
                        )
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Profile")
            .toolbarColorScheme(.dark, for: .navigationBar)
        }
    }
}

struct ProfileRow: View {
    let icon: String
    let title: String
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                .frame(width: 32, height: 32)
                .background(.white.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(title)
                .foregroundStyle(.white)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.3))
        }
        .padding()
    }
}
