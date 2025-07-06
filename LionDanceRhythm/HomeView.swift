import SwiftUI

struct HomeView: View {
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // App Title
                Text("🧠 Heritage Mind")
                    .font(.largeTitle)
                    .bold()
                    .padding(.top, 40)

                Text("Play heritage-inspired games to boost your cognition!")
                    .font(.body)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                // Navigation to Game Selection
                NavigationLink(destination: GameSelectionView()) {
                    Text("🎮 Select a Game")
                        .font(.title2)
                        .bold()
                        .foregroundColor(.white)
                        .padding()
                        .frame(width: 240)
                        .background(Color.blue)
                        .cornerRadius(12)
                        .shadow(radius: 4)
                }

                Spacer()
            }
            .padding()
        }
    }
}

