import SwiftUI

struct CongratsView: View {
    let score: Int
    let rank:  Int
    let total: Int

    var body: some View {
        VStack(spacing: 28) {
            Text("🎉 Congratulations!")
                .font(.largeTitle.bold())

            Text("Your score is \(score)")
                .font(.title2)

            Text("You are ranked \(rank) of \(total) players")
                .font(.title3)

            NavigationLink(destination: HomeView()) {
                Text("Back to Home")
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity,            // ⬅️ expands to full width
               maxHeight: .infinity,           // ⬅️ expands to full height
               alignment: .center)             // ⬅️ centers the VStack
        .multilineTextAlignment(.center)
        .padding()
    }
}
