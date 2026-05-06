import SwiftUI

struct TransactionRowView: View {
    let transaction: Transaction

    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: transaction.transactionCategory.iconName)
                .font(.body)
                .foregroundStyle(transaction.transactionCategory.color)
                .frame(width: 40, height: 40)
                .background(transaction.transactionCategory.color.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 3) {
                Text(transaction.merchant)
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.white)

                Text("\(transaction.shortDate) · \(transaction.formattedTime)")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.5))
            }

            Spacer()

            Text(transaction.formattedAmount)
                .font(.subheadline.weight(.bold))
                .foregroundStyle(.white)
        }
        .padding(.vertical, 6)
    }
}
