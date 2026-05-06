import SwiftUI

struct LoginView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var showSignUp = false
    @State private var showForgotPassword = false
    @State private var isPasswordVisible = false
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 32) {
                    Spacer()
                    
                    // Logo/Header (Refined)
                    VStack(spacing: 20) {
                        ZStack {
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.2), .clear],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "bolt.shield.fill")
                                .font(.system(size: 72))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.5), radius: 20)
                        }
                        
                        VStack(spacing: 8) {
                            Text("FinSight Lite")
                                .font(.system(size: 32, weight: .bold, design: .rounded))
                                .foregroundStyle(.white)
                            
                            Text("Smart Spending Insights")
                                .font(.subheadline)
                                .foregroundStyle(.white.opacity(0.5))
                                .tracking(1.2)
                        }
                    }
                    
                    // Form
                    VStack(spacing: 20) {
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
                        
                        HStack {
                            Spacer()
                            Button("Forgot Password?") {
                                showForgotPassword = true
                            }
                            .font(.caption.weight(.medium))
                            .foregroundStyle(Color(red: 0.5, green: 0.6, blue: 1.0))
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    // Actions
                    VStack(spacing: 20) {
                        Button {
                            viewModel.signIn()
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Sign In")
                                }
                            }
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 18))
                            .shadow(color: Color(red: 0.6, green: 0.4, blue: 1.0).opacity(0.3), radius: 10, y: 5)
                        }
                        .disabled(!viewModel.isSignInValid || viewModel.isLoading)
                        .opacity(viewModel.isSignInValid ? 1.0 : 0.6)
                        
                        HStack {
                            Text("Don't have an account?")
                                .foregroundStyle(.white.opacity(0.6))
                            Button("Sign Up") {
                                showSignUp = true
                            }
                            .font(.body.weight(.bold))
                            .foregroundStyle(Color(red: 0.5, green: 0.6, blue: 1.0))
                        }
                        .font(.subheadline)
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
            .navigationDestination(isPresented: $showSignUp) {
                SignUpView()
            }
            .sheet(isPresented: $showForgotPassword) {
                ForgotPasswordView()
            }
        }
    }
}

struct CustomTextField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 20)
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.3)))
                .foregroundStyle(.white)
                .textInputAutocapitalization(.none)
                .autocorrectionDisabled()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}

struct CustomSecureField: View {
    let placeholder: String
    @Binding var text: String
    let icon: String
    @Binding var isVisible: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundStyle(.white.opacity(0.4))
                .frame(width: 20)
            
            Group {
                if isVisible {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.3)))
                } else {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundStyle(.white.opacity(0.3)))
                }
            }
            .foregroundStyle(.white)
            
            Button {
                isVisible.toggle()
            } label: {
                Image(systemName: isVisible ? "eye.slash.fill" : "eye.fill")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.3))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
        .background(.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .overlay(
            RoundedRectangle(cornerRadius: 14)
                .stroke(.white.opacity(0.1), lineWidth: 1)
        )
    }
}
