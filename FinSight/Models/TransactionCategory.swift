import SwiftUI

enum TransactionCategory: String, CaseIterable, Identifiable, Sendable {
    case food = "Food"
    case transport = "Transport"
    case shopping = "Shopping"
    case entertainment = "Entertainment"
    case utilities = "Utilities"
    case other = "Other"

    var id: String { rawValue }

    var displayName: String { rawValue }

    var iconName: String {
        switch self {
        case .food: return "fork.knife"
        case .transport: return "car.fill"
        case .shopping: return "bag.fill"
        case .entertainment: return "film.fill"
        case .utilities: return "bolt.fill"
        case .other: return "ellipsis.circle.fill"
        }
    }

    var color: Color {
        switch self {
        case .food: return Color(red: 1.0, green: 0.45, blue: 0.35)
        case .transport: return Color(red: 0.35, green: 0.78, blue: 1.0)
        case .shopping: return Color(red: 0.85, green: 0.55, blue: 1.0)
        case .entertainment: return Color(red: 1.0, green: 0.82, blue: 0.35)
        case .utilities: return Color(red: 0.35, green: 0.92, blue: 0.65)
        case .other: return Color.gray
        }
    }

    var gradient: LinearGradient {
        switch self {
        case .food:
            return LinearGradient(colors: [Color(red: 1.0, green: 0.45, blue: 0.35), Color(red: 0.95, green: 0.3, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .transport:
            return LinearGradient(colors: [Color(red: 0.35, green: 0.78, blue: 1.0), Color(red: 0.2, green: 0.5, blue: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .shopping:
            return LinearGradient(colors: [Color(red: 0.85, green: 0.55, blue: 1.0), Color(red: 0.6, green: 0.3, blue: 0.9)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .entertainment:
            return LinearGradient(colors: [Color(red: 1.0, green: 0.82, blue: 0.35), Color(red: 0.95, green: 0.6, blue: 0.2)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .utilities:
            return LinearGradient(colors: [Color(red: 0.35, green: 0.92, blue: 0.65), Color(red: 0.2, green: 0.7, blue: 0.5)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .other:
            return LinearGradient(colors: [.gray, .gray.opacity(0.7)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}
