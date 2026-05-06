import SwiftUI

struct AddTransactionView: View {
    @StateObject private var viewModel: AddTransactionViewModel = AddTransactionViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showSuccessToast: Bool = false

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [
                        Color(red: 0.08, green: 0.05, blue: 0.18),
                        Color(red: 0.05, green: 0.03, blue: 0.12)
                    ],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        // Amount Card
                        amountSection

                        // Details Card
                        detailsSection

                        // Save Button
                        saveButton
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                    .padding(.bottom, 100)
                }
            }
            .navigationTitle("Add Transaction")
            .navigationBarTitleDisplayMode(.large)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(.white.opacity(0.7))
                }
            }
            .overlay(alignment: .top) {
                if showSuccessToast {
                    successToastView
                        .transition(.move(edge: .top).combined(with: .opacity))
                        .padding(.top, 8)
                }
            }
            .onChange(of: viewModel.didSave) { _, saved in
                if saved {
                    withAnimation(.spring(response: 0.4)) {
                        showSuccessToast = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showSuccessToast = false
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            dismiss()
                        }
                    }
                    viewModel.didSave = false
                }
            }
        }
    }

    // MARK: - Amount Section
    private var amountSection: some View {
        VStack(spacing: 16) {
            Text("Amount")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white.opacity(0.6))
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(alignment: .center, spacing: 4) {
                Text("₹")
                    .font(.system(size: 36, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.5))

                TextField("0", text: $viewModel.amountText)
                    .font(.system(size: 42, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
            }
        }
        .padding(24)
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.55, green: 0.25, blue: 0.95),
                    Color(red: 0.35, green: 0.2, blue: 0.85),
                    Color(red: 0.25, green: 0.35, blue: 0.9)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 24))
        .shadow(color: Color(red: 0.45, green: 0.25, blue: 0.95).opacity(0.4), radius: 20, y: 10)
    }

    // MARK: - Details Section
    private var detailsSection: some View {
        VStack(spacing: 20) {
            // Category Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Category")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))

                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach([TransactionCategory.food, .transport, .shopping, .entertainment, .utilities], id: \.self) { cat in
                            categoryChip(cat)
                        }
                    }
                }
            }

            // Merchant Field
            VStack(alignment: .leading, spacing: 8) {
                Text("Merchant")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))

                TextField("e.g. Swiggy, Amazon, Uber", text: $viewModel.merchant)
                    .font(.body)
                    .foregroundStyle(.white)
                    .padding(14)
                    .background(.white.opacity(0.08))
                    .clipShape(RoundedRectangle(cornerRadius: 14))
                    .overlay(
                        RoundedRectangle(cornerRadius: 14)
                            .stroke(.white.opacity(0.1), lineWidth: 1)
                    )
            }

            // Date Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Date & Time")
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.6))

                DatePicker("", selection: $viewModel.date, displayedComponents: [.date, .hourAndMinute])
                    .datePickerStyle(.compact)
                    .labelsHidden()
                    .tint(Color(red: 0.55, green: 0.4, blue: 1.0))
                    .colorScheme(.dark)
            }

            // Validation Error
            if viewModel.showValidationError {
                HStack(spacing: 8) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .foregroundStyle(.red)
                    Text(viewModel.validationMessage)
                        .font(.caption)
                        .foregroundStyle(.red.opacity(0.9))
                    Spacer()
                }
                .padding(12)
                .background(.red.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(20)
        .background(.ultraThinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 22))
    }

    // MARK: - Category Chip
    private func categoryChip(_ cat: TransactionCategory) -> some View {
        Button {
            withAnimation(.spring(response: 0.3)) {
                viewModel.selectedCategory = cat
            }
        } label: {
            HStack(spacing: 6) {
                Image(systemName: cat.iconName)
                    .font(.caption)
                Text(cat.displayName)
                    .font(.caption.weight(.medium))
            }
            .foregroundStyle(viewModel.selectedCategory == cat ? .white : .white.opacity(0.6))
            .padding(.horizontal, 14)
            .padding(.vertical, 10)
            .background(
                viewModel.selectedCategory == cat
                    ? AnyShapeStyle(cat.color.opacity(0.6))
                    : AnyShapeStyle(.white.opacity(0.08))
            )
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .stroke(viewModel.selectedCategory == cat ? cat.color : .clear, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .scaleEffect(viewModel.selectedCategory == cat ? 1.05 : 1.0)
    }

    // MARK: - Save Button
    private var saveButton: some View {
        Button {
            viewModel.save()
        } label: {
            HStack(spacing: 10) {
                Image(systemName: "plus.circle.fill")
                    .font(.title3)
                Text("Save Transaction")
                    .font(.headline)
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 18)
            .background(
                LinearGradient(
                    colors: [
                        Color(red: 0.55, green: 0.25, blue: 0.95),
                        Color(red: 0.4, green: 0.3, blue: 0.9)
                    ],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 18))
            .shadow(color: Color(red: 0.5, green: 0.25, blue: 0.95).opacity(0.5), radius: 12, y: 6)
        }
        .buttonStyle(.plain)
    }

    // MARK: - Success Toast
    private var successToastView: some View {
        HStack(spacing: 10) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(.green)
                .font(.title3)
            Text("Transaction saved successfully!")
                .font(.subheadline.weight(.medium))
                .foregroundStyle(.white)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(.ultraThinMaterial)
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(.green.opacity(0.3), lineWidth: 1)
        )
    }
}
