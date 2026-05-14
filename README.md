# FinSight

FinSight is an AI-inspired personal finance analytics app that helps users understand spending behavior through intelligent insights, interactive visualizations, and real-time expense tracking.

![Platform](https://img.shields.io/badge/Platform-iOS%2017+-blue?logo=apple)
![Swift](https://img.shields.io/badge/Swift-5.9-orange?logo=swift)
![Architecture](https://img.shields.io/badge/Architecture-MVVM-green)
![Backend](https://img.shields.io/badge/Backend-Firebase-yellow?logo=firebase)

---

## ✨ Features

- **Smart Spending Insights** — A rule-based engine that detects late-night spending, weekend spikes, category dominance, top merchants, and unusually large transactions.
- **Interactive Dashboard** — View total spending, average spend, category donut chart, weekly trend line chart, and recent transaction list — all in one glance.
- **Category Breakdown** — Spending organized into Food, Transport, Shopping, Entertainment, Utilities, and Other with distinct icons, colors, and gradients.
- **Add Transactions** — Manually log new transactions with merchant, amount, category, date, and time.
- **Behavioral Insights Cards** — Horizontally scrollable insight cards with contextual icons and severity types (info, warning, alert).
- **Authentication** — Sign up, log in, forgot password, and onboarding flows powered by Firebase Auth.
- **Profile Management** — Account details, notification preferences, and security settings.
- **Core Data Persistence** — Offline-first storage with automatic mock data seeding on first launch.
- **Premium Dark UI** — Deep purple/blue gradients, glassmorphism effects, smooth animations, and a polished splash screen.

---

## 🏗️ Architecture

The project follows the **MVVM (Model-View-ViewModel)** pattern:

```
FinSight/
├── Models/
│   ├── Transaction.swift          # Transaction data model
│   ├── TransactionCategory.swift  # Category enum with icons, colors, gradients
│   └── Insight.swift              # Insight model for behavioral analysis
├── Views/
│   ├── DashboardView.swift        # Main dashboard with charts & insights
│   ├── InsightsView.swift         # Dedicated insights list
│   ├── CategoriesView.swift       # Category breakdown view
│   ├── CategoryDetailView.swift   # Per-category drill-down
│   ├── AddTransactionView.swift   # New transaction form
│   ├── ProfileView.swift          # User profile & settings
│   ├── AccountDetailsView.swift   # Account management
│   ├── NotificationsView.swift    # Notification preferences
│   ├── SecurityView.swift         # Password & security settings
│   ├── LoginView.swift            # Login screen
│   ├── SignUpView.swift           # Registration screen
│   ├── ForgotPasswordView.swift   # Password reset
│   ├── OnboardingView.swift       # First-launch onboarding
│   ├── SplashView.swift           # Animated splash screen
│   ├── RootView.swift             # Auth-state router
│   ├── MainTabView.swift          # Tab bar navigation
│   └── Components/
│       ├── InsightCardView.swift   # Reusable insight card
│       └── TransactionRowView.swift# Transaction list row
├── ViewModels/
│   ├── TransactionViewModel.swift # Transaction state & computed properties
│   ├── DashboardViewModel.swift   # Dashboard data aggregation
│   ├── CategoryViewModel.swift    # Category filtering & stats
│   ├── InsightViewModel.swift     # Insight generation coordinator
│   ├── AddTransactionViewModel.swift # New transaction form logic
│   └── AuthViewModel.swift        # Authentication state management
├── Services/
│   ├── InsightEngine.swift        # Rule-based behavioral analysis engine
│   ├── PersistenceService.swift   # Core Data CRUD & mock data seeding
│   ├── AuthService.swift          # Firebase Auth wrapper
│   ├── FirebaseService.swift      # Firebase Firestore integration
│   └── APIService.swift           # Network layer abstraction
└── Resources/
    └── mock_transactions.json     # Sample data for first-launch experience
```

---

## 🔍 Insight Engine

The `InsightEngine` analyzes transactions using five rules:

| Rule | Trigger | Type |
|------|---------|------|
| **Late Night Spending** | >30% of food spending after 9 PM | ⚠️ Warning |
| **Weekend Spending Spike** | Weekend daily avg > weekday daily avg | 🚨 Alert |
| **Category Dominance** | Any single category >40% of total | ℹ️ Info |
| **Top Merchant** | Merchant with highest aggregate spend | ℹ️ Info |
| **Unusually Large Transaction** | Single transaction >3× the average | 🚨 Alert |

---

## 📊 Charts & Visualization

Built with **Swift Charts**:
- **Donut Chart** — Category breakdown with percentage labels
- **Line + Area Chart** — Weekly spending trend with Catmull-Rom interpolation
- Animated chart entrance with staggered timing

---

## 🚀 Getting Started

### Prerequisites

- **Xcode 15+**
- **iOS 17+** deployment target
- A Firebase project with Authentication and Firestore enabled

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Somdatta23/FinSight.git
   cd FinSight
   ```

2. Open the project in Xcode:
   ```bash
   open FinSight.xcodeproj
   ```

3. **Firebase Setup** — Replace `GoogleService-Info.plist` with your own from the [Firebase Console](https://console.firebase.google.com/).

4. Build and run on a simulator or device (iOS 17+).

> **Note:** On first launch, the app seeds mock transaction data automatically so the dashboard is populated right away.

---

## 🛠️ Tech Stack

| Layer | Technology |
|-------|-----------|
| UI Framework | SwiftUI |
| Charts | Swift Charts |
| Architecture | MVVM |
| Authentication | Firebase Auth |
| Cloud Database | Firebase Firestore |
| Local Storage | Core Data |
| Language | Swift 5.9 |
| Min Deployment | iOS 17 |

---

## 📄 License

This project is for personal/educational use.

---

## 👤 Author

**Somdatta Sikdar**

---
