import SwiftUI

struct GameSelectionView: View {
    var body: some View {
        List {
            // ── Lion Dance Rhythm (opens instructions first) ─────────
            NavigationLink {
                GameInstructionsView()
            } label: {
                Label("Lion Dance Rhythm", systemImage: "music.note")
            }

            // ── Wet Market Recall (placeholder) ─────────────────────
            NavigationLink {
                Text("Wet Market Recall coming soon!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Wet Market Recall")
            } label: {
                Label("Wet Market Recall", systemImage: "cart")
            }

            // ── Tap the MRT (placeholder) ───────────────────────────
            NavigationLink {
                Text("Tap the MRT coming soon!")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .navigationTitle("Tap the MRT")
            } label: {
                Label("Tap the MRT", systemImage: "tram.fill")
            }
        }
        .navigationTitle("Select a Game")
        .frame(minWidth: 320)           // keeps list from expanding too wide
    }
}

#Preview { NavigationStack { GameSelectionView() } }
