import SwiftUI
import Combine
import AVFoundation

// MARK: – Sound helper (unchanged)
final class SoundManager {
    static let shared = SoundManager()
    private var player: AVAudioPlayer?
    func play(_ name: String, ext: String = "wav") {
        guard let url = Bundle.main.url(forResource: name, withExtension: ext) else { return }
        player = try? AVAudioPlayer(contentsOf: url)
        player?.play()
    }
}

// MARK: – Game view
struct LionDanceRhythmView: View {
    // Senior-friendly tuning
    private let beatsPerBar  = 4
    private let beatWindow   : TimeInterval = 0.35
    private let sessionSecs  = 30
    private let startBeat    : TimeInterval = 1.8
    private let minBeat      : TimeInterval = 1.3

    // Beat state
    @State private var beatInterval = 1.8
    @State private var beatTimer    = Timer.publish(every: 1.8, on: .main, in: .common).autoconnect()
    @State private var currentBeat  = 0
    @State private var lastBeatTime = Date()

    // Countdown
    @State private var secondsLeft  = 30
    @State private var countdown    = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var playing      = false

    // Score + UI
    @State private var score = 0
    @State private var msg   = "Tap Start"

    // Leaderboard nav
    @State private var navigateCongrats = false
    @State private var congratsData: (score: Int, rank: Int, total: Int) = (0,0,0)

    var body: some View {
        NavigationStack {
            VStack(spacing: 32) {
                Text("🦁 Lion Dance Rhythm").font(.title.bold())

                // Lion-head beat indicators
                HStack(spacing: 30) {
                    ForEach(0..<beatsPerBar, id: \.self) { i in
                        Image("lionHead")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 70, height: 70)
                            .opacity(i == currentBeat ? 1.0 : 0.25)
                            .scaleEffect(i == currentBeat ? 1.25 : 0.9)
                            .animation(.easeInOut(duration: 0.25), value: currentBeat)
                    }
                }

                Text("Time \(secondsLeft)s").font(.headline)

                // Drum tap (custom image)
                Button(action: drumTapped) {
                    Image("drum")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .shadow(radius: 8)
                }
                .disabled(!playing)

                Text(msg)

                HStack {
                    Button("Start")  { startGame() }
                    Button("Reset")  { resetGame() }
                }
                .buttonStyle(.borderedProminent)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding()
            .onReceive(beatTimer) { _ in if playing { nextBeat() } }
            .onReceive(countdown) { _ in if playing { tick() } }
            .navigationTitle("Lion Dance")

            // Hidden nav → Congrats
            NavigationLink(
                destination: CongratsView(score: congratsData.score,
                                          rank:  congratsData.rank,
                                          total: congratsData.total),
                isActive: $navigateCongrats) { EmptyView() }
        }
    }

    // MARK: – Game actions
    private func drumTapped() {
        guard playing else { return }
        SoundManager.shared.play("drum")                 // tap sound
        let Δ = Date().timeIntervalSince(lastBeatTime)
        if abs(Δ) <= beatWindow { score += 1; msg = "Great 🎉" }
        else                    { msg = Δ < 0 ? "Early" : "Late" }
    }

    private func nextBeat() {
        currentBeat = (currentBeat + 1) % beatsPerBar
        lastBeatTime = Date()
    }

    private func tick() {
        secondsLeft -= 1
        if secondsLeft == 0 { finishGame() }
    }

    // MARK: – Lifecycle
    private func startGame() {
        resetGame()
        playing = true
        msg = "Tap when the lion jumps!"
        lastBeatTime = Date()
        restartBeatTimer(interval: startBeat)
        restartCountdown()
    }

    private func finishGame() {
        playing = false
        beatTimer.upstream.connect().cancel()
        countdown.upstream.connect().cancel()

        let result = LeaderboardManager.record(score: score)
        congratsData = (score, result.rank, result.total)
        navigateCongrats = true
    }

    private func resetGame() {
        beatTimer.upstream.connect().cancel()
        countdown.upstream.connect().cancel()
        score = 0
        secondsLeft = sessionSecs
        currentBeat = 0
        beatInterval = startBeat
        msg = "Tap Start"
        playing = false
    }

    // MARK: – Timer helpers
    private func restartBeatTimer(interval: TimeInterval) {
        beatTimer.upstream.connect().cancel()
        beatInterval = max(minBeat, interval)
        beatTimer = Timer.publish(every: beatInterval, on: .main, in: .common).autoconnect()
    }
    private func restartCountdown() {
        countdown.upstream.connect().cancel()
        countdown = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    }
}

