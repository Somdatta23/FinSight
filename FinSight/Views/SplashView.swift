import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var logoOpacity = 0.0
    @State private var logoScale = 0.8
    @State private var textOpacity = 0.0
    
    var body: some View {
        ZStack {
            // Background Gradient matching App Icon
            LinearGradient(
                colors: [
                    Color(red: 0.35, green: 0.1, blue: 0.6), // Purple
                    Color(red: 0.1, green: 0.2, blue: 0.8), // Indigo
                    Color(red: 0.0, green: 0.4, blue: 0.9)  // Blue
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: 24) {
                // App Logo / Symbol (Using image we generated)
                Image("AppIcon-1024") // Since it's in Assets, we can reference it
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(RoundedRectangle(cornerRadius: 28))
                    .shadow(color: .black.opacity(0.3), radius: 20, x: 0, y: 10)
                    .opacity(logoOpacity)
                    .scaleEffect(logoScale)
                
                VStack(spacing: 8) {
                    Text("FinSight Lite")
                        .font(.system(size: 42, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    
                    Text("Smart Spending Insights")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.7))
                }
                .opacity(textOpacity)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.2)) {
                logoOpacity = 1.0
                logoScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 1.0).delay(0.5)) {
                textOpacity = 1.0
            }
        }
    }
}

#Preview {
    SplashView()
}
