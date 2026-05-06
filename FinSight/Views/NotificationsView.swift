import SwiftUI

struct NotificationsView: View {
    @AppStorage("pushNotificationsEnabled") private var pushEnabled = true
    @AppStorage("spendingAlertsEnabled") private var spendingAlertsEnabled = true
    @AppStorage("monthlySummaryEnabled") private var monthlySummaryEnabled = true
    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
            
            VStack(spacing: 24) {
                VStack(spacing: 0) {
                    ToggleRow(icon: "bell.fill", color: .purple, title: "Push Notifications", isOn: $pushEnabled)
                    Divider().background(.white.opacity(0.1))
                    ToggleRow(icon: "dollarsign.circle.fill", color: .green, title: "Spending Alerts", isOn: $spendingAlertsEnabled)
                    Divider().background(.white.opacity(0.1))
                    ToggleRow(icon: "doc.text.fill", color: .blue, title: "Monthly Summary", isOn: $monthlySummaryEnabled)
                }
                .background(.white.opacity(0.05))
                .clipShape(RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 16)
                
                Text("Management of your notification preferences. These settings are stored locally on this device.")
                    .font(.caption)
                    .foregroundStyle(.white.opacity(0.4))
                    .padding(.horizontal, 24)
                    .multilineTextAlignment(.center)
                
                Spacer()
            }
            .padding(.top, 24)
        }
        .navigationTitle("Notifications")
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct ToggleRow: View {
    let icon: String
    let color: Color
    let title: String
    @Binding var isOn: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .foregroundStyle(color)
                .frame(width: 32, height: 32)
                .background(color.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 8))
            
            Text(title)
                .foregroundStyle(.white)
            
            Spacer()
            
            Toggle("", isOn: $isOn)
                .tint(color)
        }
        .padding()
    }
}
