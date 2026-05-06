import SwiftUI
import FirebaseAuth

struct AccountDetailsView: View {
    @StateObject private var viewModel = AuthViewModel()
    @State private var isEditing = false
    @State private var newName = ""
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 24) {
                // Info Card
                VStack(spacing: 0) {
                    InfoRow(label: "Full Name", value: viewModel.fullName.isEmpty ? "Not Set" : viewModel.fullName)
                    Divider().background(.white.opacity(0.1))
                    InfoRow(label: "Email", value: viewModel.email)
                    Divider().background(.white.opacity(0.1))
                    if let creationDate = AuthService.shared.currentUser?.metadata.creationDate {
                        InfoRow(label: "Account Created", value: creationDate.formatted(date: .abbreviated, time: .omitted))
                    }
                }
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                
                // Edit Button
                Button {
                    newName = viewModel.fullName
                    isEditing = true
                } label: {
                    Text("Edit Profile")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(LinearGradient(colors: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)], startPoint: .leading, endPoint: .trailing))
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
            .padding(.top, 24)
        }
        .navigationTitle("Account Details")
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            // Ensure VM matches current user
            if let user = AuthService.shared.currentUser {
                viewModel.fullName = user.displayName ?? ""
                viewModel.email = user.email ?? ""
            }
        }
        .sheet(isPresented: $isEditing) {
            EditProfileView(newName: $newName) {
                AuthService.shared.updateDisplayName(newName) { success in
                    if success {
                        viewModel.fullName = newName
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text(label)
                .foregroundStyle(.white.opacity(0.6))
            Spacer()
            Text(value)
                .foregroundStyle(.white)
                .fontWeight(.medium)
        }
        .padding()
    }
}

struct EditProfileView: View {
    @Binding var newName: String
    @Environment(\.dismiss) var dismiss
    var onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
                
                VStack(spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Display Name")
                            .foregroundStyle(.white.opacity(0.6))
                            .font(.caption)
                        
                        TextField("Enter your name", text: $newName)
                            .foregroundStyle(.white)
                            .padding()
                            .background(.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
                .padding(.top, 40)
            }
            .navigationTitle("Edit Profile")
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                        .foregroundStyle(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        onSave()
                        dismiss()
                    }
                    .foregroundStyle(Color(red: 0.6, green: 0.4, blue: 1.0))
                    .fontWeight(.bold)
                }
            }
        }
    }
}

