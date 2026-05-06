import SwiftUI

struct OnboardingView: View {
    @AppStorage("hasCompletedOnboarding") var hasCompletedOnboarding: Bool = false
    @State private var currentPage = 0
    
    let onboardingSteps = [
        OnboardingStep(
            title: "Track Every Rupee",
            description: "Monitor all your expenses in one place.",
            imageName: "creditcard.and.123",
            gradient: [Color(red: 0.6, green: 0.4, blue: 1.0), Color(red: 0.4, green: 0.6, blue: 1.0)]
        ),
        OnboardingStep(
            title: "Smart Spending Insights",
            description: "Discover spending patterns and improve financial habits.",
            imageName: "chart.line.uptrend.xyaxis",
            gradient: [Color(red: 0.4, green: 0.6, blue: 1.0), Color(red: 0.2, green: 0.8, blue: 1.0)]
        ),
        OnboardingStep(
            title: "Secure Cloud Sync",
            description: "Access your financial data anytime, across devices.",
            imageName: "icloud.and.arrow.down",
            gradient: [Color(red: 0.2, green: 0.8, blue: 1.0), Color(red: 0.1, green: 0.9, blue: 0.7)]
        )
    ]
    
    var body: some View {
        ZStack {
            // Background
            Color(red: 0.05, green: 0.03, blue: 0.12).ignoresSafeArea()
            
            VStack {
                HStack {
                    Spacer()
                    Button("Skip") {
                        hasCompletedOnboarding = true
                    }
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.white.opacity(0.5))
                    .padding()
                }
                
                TabView(selection: $currentPage) {
                    ForEach(0..<onboardingSteps.count, id: \.self) { index in
                        OnboardingCardView(step: onboardingSteps[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(.page(indexDisplayMode: .always))
                .animation(.easeInOut, value: currentPage)
                
                Spacer()
                
                VStack(spacing: 16) {
                    Button {
                        if currentPage < onboardingSteps.count - 1 {
                            currentPage += 1
                        } else {
                            hasCompletedOnboarding = true
                        }
                    } label: {
                        Text(currentPage == onboardingSteps.count - 1 ? "Get Started" : "Next")
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(
                                LinearGradient(
                                    colors: onboardingSteps[currentPage].gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 16))
                            .shadow(color: onboardingSteps[currentPage].gradient[0].opacity(0.3), radius: 10, y: 5)
                    }
                    .padding(.horizontal, 40)
                    .buttonStyle(ScaleButtonStyle())
                }
                .padding(.bottom, 50)
            }
        }
    }
}

struct OnboardingStep {
    let title: String
    let description: String
    let imageName: String
    let gradient: [Color]
}

struct OnboardingCardView: View {
    let step: OnboardingStep
    
    var body: some View {
        VStack(spacing: 40) {
            ZStack {
                Circle()
                    .fill(step.gradient[0].opacity(0.1))
                    .frame(width: 250, height: 250)
                
                Image(systemName: step.imageName)
                    .font(.system(size: 100))
                    .foregroundStyle(
                        LinearGradient(
                            colors: step.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .shadow(color: step.gradient[0].opacity(0.4), radius: 20)
            }
            .padding(.top, 40)
            
            VStack(spacing: 16) {
                Text(step.title)
                    .font(.title.weight(.bold))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                
                Text(step.description)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.6))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
            }
            
            Spacer()
        }
    }
}

struct ScaleButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.spring(response: 0.3), value: configuration.isPressed)
    }
}
