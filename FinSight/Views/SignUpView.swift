import SwiftUI

struct SignUpView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var isPasswordVisible = false
    @State private var isConfirmPasswordVisible = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Text("Create Account")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Join FinSight to sync your data across devices")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                
                // Form
                VStack(spacing: 20) {
                    CustomTextField(
                        placeholder: "Full Name (Optional)",
                        text: $viewModel.fullName,
                        icon: "person.fill"
                    )
                    
                    CustomTextField(
                        placeholder: "Email",
                        text: $viewModel.email,
                        icon: "envelope.fill"
                    )
                    
                    CustomSecureField(
                        placeholder: "Password",
                        text: $viewModel.password,
                        icon: "lock.fill",
                        isVisible: $isPasswordVisible
                    )
                    
                    CustomSecureField(
                        placeholder: "Confirm Password",
                        text: $viewModel.confirmPassword,
                        icon: "lock.shield.fill",
                        isVisible: $isConfirmPasswordVisible
                    )
                }
                .padding(.horizontal, 24)
                
                // Actions
                VStack(spacing: 20) {
                    Button {
                        viewModel.signUp()
                    } label: {
                        Group {
                            if viewModel.isLoading {
                                ProgressView().tint(.white)
                            } else {
                                Text("Create Account")
                            }
                        }
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(
                            LinearGradient(
                                colors: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.2, green: 0.8, blue: 1.0)],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 18))
                        .shadow(color: Color(red: 0.4, green: 0.6, blue: 1.0).opacity(0.3), radius: 10, y: 5)
                    }
                    .disabled(!viewModel.isSignUpValid || viewModel.isLoading)
                    .opacity(viewModel.isSignUpValid ? 1.0 : 0.6)
                    
                    Button("Already have an account? Sign In") {
                        dismiss()
                    }
                    .font(.subheadline.weight(.bold))
                    .foregroundStyle(Color(red: 0.5, green: 0.6, blue: 1.0))
                }
                .padding(.horizontal, 24)
                
                if let error = viewModel.authError {
                    Text(error)
                        .font(.caption)
                        .foregroundStyle(.red)
                        .padding(.horizontal, 24)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .padding(10)
                        .background(.white.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        }
    }
}

