import SwiftUI
import FirebaseAuth

struct SecurityView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showChangePassword = false
    @State private var oldPassword = ""
    @State private var newPassword = ""
    @State private var confirmNewPassword = ""
    @State private var showDeleteAlert = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Security Actions
                VStack(spacing: 0) {
                    SecurityRow(icon: "key.fill", title: "Change Password") {
                        showChangePassword = true
                    }
                    Divider().background(.white.opacity(0.1))
                    SecurityRow(icon: "envelope.badge.fill", title: "Reset via Email") {
                        viewModel.resetPassword()
                    }
                }
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                
                // Account Actions
                VStack(spacing: 0) {
                    SecurityRow(icon: "power", title: "Log Out", color: .red) {
                        viewModel.signOut()
                    }
                    Divider().background(.white.opacity(0.1))
                    SecurityRow(icon: "trash.fill", title: "Delete Account", color: .red) {
                        showDeleteAlert = true
                    }
                }
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                
                if let error = viewModel.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
            .padding(.top, 24)
        }
        .navigationTitle("Security")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            if let user = AuthService.shared.currentUser {
                viewModel.email = user.email ?? ""
            }
        }
        .sheet(isPresented: $showChangePassword) {
            ChangePasswordView(newPassword: $newPassword, confirmPassword: $confirmNewPassword) {
                AuthService.shared.updatePassword(newPassword: newPassword) { success in
                    if success {
                        showChangePassword = false
                        newPassword = ""
                        confirmNewPassword = ""
                    }
                }
            }
        }
        .alert("Delete Account", isPresented: $showDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                // UI Placeholder only as per requirements
                print("Delete account requested")
            }
        } message: {
            Text("Are you sure you want to delete your account? This action cannot be undone and all your data will be permanently removed.")
        }
    }
}

struct SecurityRow: View {
    let icon: String
    let title: String
    var color: Color = Color(red: 0.6, green: 0.4, blue: 1.0)
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .foregroundStyle(color)
                    .frame(width: 32, height: 32)
                    .background(color.opacity(0.1))
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
}

struct ChangePasswordView: View {
    @Binding var newPassword: String
    @Binding var confirmPassword: String
    @Environment(\.dismiss) var dismiss
    var onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("New Password")
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.caption)
                            SecureField("", text: $newPassword)
                                .foregroundStyle(.white)
                                .padding()
                                .background(.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Confirm New Password")
                                .foregroundStyle(.white.opacity(0.6))
                                .font(.caption)
                            SecureField("", text: $confirmPassword)
                                .foregroundStyle(.white)
                                .padding()
                                .background(.white.opacity(0.1))
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Change Password")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Update") {
                        if !newPassword.isEmpty && newPassword == confirmPassword {
                            onSave()
                            dismiss()
                        }
                    }
                    .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                    .fontWeight(.bold)
                    .disabled(newPassword.isEmpty || newPassword != confirmPassword)
                }
            }
        }
    }
}
