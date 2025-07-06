import SwiftUI
import Combine
import AVFoundation

// MARK: – Sound helper
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
    // Tunables for seniors
    private let beatsPerBar = 4
    private let beatWindow  : TimeInterval = 0.35   // ± 350 ms
    private let sessionSecs = 30
    private let startBeat   : TimeInterval = 1.8    // start slow (≈33 BPM)
    private let minBeat     : TimeInterval = 1.3    // never faster than 46 BPM
    
    // Beat state
    @State private var beatInterval = 1.8
    @State private var beatTimer    = Timer.publish(every: 1.8, on: .main, in: .common).autoconnect()
    @State private var currentBeat  = 0
    @State private var lastBeatTime = Date()
    
    // Countdown
    @State private var secondsLeft = 30
    @State private var countdown   = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    @State private var playing     = false
    
    // Score
    @State private var score = 0
    @State private var msg   = "Tap Start"
    
    var body: some View {
        VStack(spacing: 28) {
            Text("🦁 Lion Dance Rhythm").font(.title.bold())
            
            // Beat dots
            HStack(spacing: 24) {
                ForEach(0..<beatsPerBar, id: \.self) { i in
                    Circle()
                        .fill(i == currentBeat ? .red : .gray.opacity(0.3))
                        .frame(width: 48, height: 48)
                        .scaleEffect(i == currentBeat ? 1.25 : 1)
                        .animation(.easeInOut(duration: 0.25), value: currentBeat)
                }
            }
            
            Text("Time \(secondsLeft)s").font(.headline)
            
            Button(action: drumTapped) {
                Image(systemName: "music.note")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 90, height: 90)
                    .padding(34)
                    .background(Color.yellow)
                    .clipShape(Circle())
                    .shadow(radius: 8)
            }
            .disabled(!playing)
            
            Text(msg)
            
            HStack {
                Button("Start") { startGame() }
                Button("Reset") { resetGame() }
            }
            .buttonStyle(.borderedProminent)
        }
        .padding()
        // Timers
        .onReceive(beatTimer) { _ in if playing { nextBeat() } }
        .onReceive(countdown) { _ in if playing { tick() } }
        .navigationTitle("Lion Dance")
    }
    
    // MARK: – Game actions
    private func drumTapped() {
        guard playing else { return }
        SoundManager.shared.play("drum")
        let δ = Date().timeIntervalSince(lastBeatTime)
        if abs(δ) <= beatWindow { score += 1; msg = "Great 🎉" }
        else                     { msg = δ < 0 ? "Early" : "Late" }
    }
    
    private func nextBeat() {
        currentBeat = (currentBeat + 1) % beatsPerBar
        lastBeatTime = Date()
    }
    
    private func tick() {
        secondsLeft -= 1
        if secondsLeft == 0 { finish() }
    }
    
    // MARK: – Lifecycle
    private func startGame() {
        resetGame()
        playing     = true
        msg         = "Tap on each red beat!"
        lastBeatTime = Date()
        restartBeatTimer(interval: startBeat)
        restartCountdown()
    }
    private func finish() {
        playing = false
        beatTimer.upstream.connect().cancel()
        countdown.upstream.connect().cancel()
        msg = "⏰ Time’s up! Score \(score)"
    }
    private func resetGame() {
        beatTimer.upstream.connect().cancel()
        countdown.upstream.connect().cancel()
        score       = 0
        secondsLeft = sessionSecs
        currentBeat = 0
        beatInterval = startBeat
        msg         = "Tap Start"
        playing     = false
    }
    
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

