import SwiftUI

struct GameInstructionsView: View {
    @State private var navigateToGame = false     // triggers game start

    var body: some View {
        VStack(spacing: 30) {

            // Header
            Text("🦁 Lion Dance Rhythm")
                .font(.largeTitle.weight(.bold))
                .padding(.top, 40)

            // Hero image (optional)
            Image("lionhead")          // be sure asset exists
                .resizable()
                .scaledToFit()
                .frame(height: 120)

            // Instructions
            VStack(alignment: .leading, spacing: 15) {
                Text("How to Play").font(.title2.bold())

                Label("You have **30 seconds**.", systemImage: "clock")
                Label("Tap the **drum** in sync with the beat.", systemImage: "hand.tap")
                Label("Good timing lights the **lion** head!", systemImage: "star.fill")
                Label("More accurate taps → higher score.", systemImage: "chart.bar.fill")
            }
            .labelStyle(.titleAndIcon)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.horizontal)

            Spacer()

            // NavigationLink hidden – becomes active when user taps Start
            NavigationLink(destination: LionDanceRhythmView(),
                           isActive: $navigateToGame) { EmptyView() }

            // Start button
            Button {
                navigateToGame = true
            } label: {
                Text("Start Game 🎵")
                    .font(.title2.bold())
                    .foregroundColor(.white)
                    .padding(.vertical, 14)
                    .frame(width: 240)
                    .background(Color.orange)
                    .cornerRadius(15)
                    .shadow(radius: 5, y: 3)
            }
            .padding(.bottom)
        }
        .multilineTextAlignment(.leading)
        .padding()
    }
}

#Preview { GameInstructionsView() }

