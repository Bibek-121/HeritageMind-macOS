import SwiftUI
import Foundation   // for ISO8601DateFormatter

struct MMSEView: View {
    // ── User input ───────────────────────────
    @State private var dateInput     = ""
    @State private var locationInput = ""

    // ── Result & UI state ────────────────────
    @State private var score     = 0
    @State private var showScore = false
    @State private var showToast = false       // brief “Sent!” notice

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("🧠 MMSE Check")
                    .font(.largeTitle.bold())
                    .padding(.top, 40)

                // — Questions —
                VStack(alignment: .leading, spacing: 18) {
                    Text("1️⃣  Today’s date (DD/MM/YYYY)")
                    TextField("E.g. 05/07/2025", text: $dateInput)
                        .textFieldStyle(.roundedBorder)

                    Text("2️⃣  Which area of Singapore do you live in?")
                    TextField("E.g. Bedok, Yishun", text: $locationInput)
                        .textFieldStyle(.roundedBorder)
                }
                .padding()

                Button("Submit") { checkAnswers() }
                    .buttonStyle(.borderedProminent)

                // — Result —
                if showScore {
                    Text("Score: \(score) / 10")
                        .font(.title2)
                        .padding(.top, 8)

                    if showToast {
                        Text("✅ Score sent to physician")
                            .font(.caption)
                            .foregroundColor(.green)
                    }

                    NavigationLink("Continue to Games") {
                        HomeView()
                    }
                    .buttonStyle(.borderedProminent)
                }

                Spacer()
            }
            .padding()
        }
    }

    // MARK: - Scoring logic
    private func checkAnswers() {
        // Reset and score
        score = 0
        let formatter = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        let todayString = formatter.string(from: Date())

        if dateInput.trimmingCharacters(in: .whitespacesAndNewlines) == todayString {
            score += 5
        }
        if !locationInput.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            score += 5
        }

        showScore = true

        // Fire-and-forget HTTP POST
        Task { await sendMMSEToWebhook(score: score) }
    }

    // MARK: - Network: POST score to Webhook.site
    private func sendMMSEToWebhook(score: Int) async {
        guard let url = URL(string: "https://webhook.site/4ac5c638-ccab-481e-8152-9864f852b5a4") else { return }

        // JSON payload
        let payload: [String: Any] = [
            "recipient": "e0272320@u.nus.edu",
            "subject": "MMSE Score Report",
            "score":   score,
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.addValue("application/json", forHTTPHeaderField: "Content-Type")
        req.httpBody = try? JSONSerialization.data(withJSONObject: payload)

        do {
            let (_, response) = try await URLSession.shared.data(for: req)
            if let http = response as? HTTPURLResponse, http.statusCode == 200 {
                // brief success toast
                withAnimation { showToast = true }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    withAnimation { showToast = false }
                }
            } else {
                print("⚠️ Webhook returned status \( (response as? HTTPURLResponse)?.statusCode ?? 0)")
            }
        } catch {
            print("❌ POST failed:", error.localizedDescription)
        }
    }
}

