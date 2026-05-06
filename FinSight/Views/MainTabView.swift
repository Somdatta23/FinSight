import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Int = 0
    @State private var showAddTransaction: Bool = false

    init() {
        let appearance: UITabBarAppearance = UITabBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor(red: 0.06, green: 0.04, blue: 0.14, alpha: 0.95)

        let itemAppearance: UITabBarItemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.iconColor = UIColor.white.withAlphaComponent(0.4)
        itemAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white.withAlphaComponent(0.4)]
        itemAppearance.selected.iconColor = UIColor(red: 0.55, green: 0.4, blue: 1.0, alpha: 1.0)
        itemAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 0.55, green: 0.4, blue: 1.0, alpha: 1.0)]

        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance

        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Image(systemName: "chart.bar.fill")
                    Text("Dashboard")
                }
                .tag(0)

            InsightsView()
                .tabItem {
                    Image(systemName: "lightbulb.fill")
                    Text("Insights")
                }
                .tag(1)

            CategoriesView()
                .tabItem {
                    Image(systemName: "square.grid.2x2.fill")
                    Text("Categories")
                }
                .tag(2)

            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle.fill")
                    Text("Profile")
                }
                .tag(3)
        }
    }
}
