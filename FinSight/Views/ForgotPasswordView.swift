import SwiftUI

struct ForgotPasswordView: View {
    @StateObject private var viewModel = AuthViewModel()
    @Environment(\.dismiss) var dismiss
    @State private var emailSent = false
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 32) {
                // Header
                VStack(spacing: 12) {
                    Image(systemName: "lock.rotation")
                        .font(.system(size: 64))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .padding(.bottom, 10)
                    
                    Text("Forgot Password?")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Enter your email and we'll send you a link to reset your password.")
                        .font(.subheadline)
                        .foregroundStyle(.white.opacity(0.5))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 40)
                }
                .padding(.top, 40)
                
                if emailSent {
                    // Success Message
                    VStack(spacing: 20) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 64))
                            .foregroundStyle(.green)
                        
                        Text("Reset Link Sent!")
                            .font(.headline)
                            .foregroundStyle(.white)
                        
                        Text("Please check your email inbox for instructions to reset your password.")
                            .font(.subheadline)
                            .foregroundStyle(.white.opacity(0.7))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                        
                        Button("Back to Sign In") {
                            dismiss()
                        }
                        .font(.headline)
                        .foregroundStyle(Color(red: 0.5, green: 0.6, blue: 1.0))
                        .padding(.top, 20)
                    }
                    .transition(.scale.combined(with: .opacity))
                } else {
                    // Form
                    VStack(spacing: 24) {
                        CustomTextField(
                            placeholder: "Email Address",
                            text: $viewModel.email,
                            icon: "envelope.fill"
                        )
                        
                        Button {
                            viewModel.resetPassword()
                            // Simulate success feedback - in production, VM should handle this state
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if viewModel.authError == nil {
                                    withAnimation {
                                        emailSent = true
                                    }
                                }
                            }
                        } label: {
                            Group {
                                if viewModel.isLoading {
                                    ProgressView().tint(.white)
                                } else {
                                    Text("Send Reset Link")
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
                        }
                        .disabled(viewModel.email.isEmpty || viewModel.isLoading)
                        .opacity(viewModel.email.isEmpty ? 0.6 : 1.0)
                    }
                    .padding(.horizontal, 24)
                }
                
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
    }
}
