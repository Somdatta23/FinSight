import SwiftUI

enum InsightType: String, Sendable {
    case alert
    case info
    case warning
    case positive
}

struct Insight: Identifiable, Sendable {
    let id: String
    let title: String
    let description: String
    let iconName: String
    let type: InsightType

    var typeColor: Color {
        switch type {
        case .alert: return .red
        case .info: return .blue
        case .warning: return .orange
        case .positive: return .green
        }
    }
}
