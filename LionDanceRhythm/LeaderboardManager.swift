import Foundation

struct LeaderboardManager {
    private static let key = "lionDanceScores"

    static func record(score: Int) -> (rank: Int, total: Int) {
        var scores = UserDefaults.standard.array(forKey: key) as? [Int] ?? []
        scores.append(score)
        scores.sort(by: >)
        UserDefaults.standard.set(scores, forKey: key)

        if let index = scores.firstIndex(of: score) {
            return (index + 1, scores.count)
        }
        return (scores.count, scores.count)
    }
}

