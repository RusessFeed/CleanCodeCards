import Foundation

enum ReviewRating: String, CaseIterable, Identifiable {
    case again = "Again"
    case hard = "Hard"
    case good = "Good"
    case easy = "Easy"

    var id: String { rawValue }

    var systemImage: String {
        switch self {
        case .again:
            return "arrow.counterclockwise"
        case .hard:
            return "flame"
        case .good:
            return "checkmark.circle"
        case .easy:
            return "sparkles"
        }
    }
}

struct ReviewSchedule: Equatable {
    let intervalDays: Int
    let easeFactor: Double
    let repetitionCount: Int

    var summaryText: String {
        if intervalDays == 0 {
            return "Review today"
        }

        if intervalDays == 1 {
            return "Review tomorrow"
        }

        return "Review in \(intervalDays) days"
    }
}

struct ReviewPlanOption: Identifiable, Equatable {
    let rating: ReviewRating
    let schedule: ReviewSchedule

    var id: String { rating.id }
}

enum SpacedRepetitionEngine {
    static let minimumEaseFactor = 1.3
    static let initial = ReviewSchedule(intervalDays: 0, easeFactor: 2.5, repetitionCount: 0)

    static func nextSchedule(after current: ReviewSchedule, rating: ReviewRating) -> ReviewSchedule {
        switch rating {
        case .again:
            return ReviewSchedule(
                intervalDays: 1,
                easeFactor: adjustedEaseFactor(current.easeFactor, by: -0.25),
                repetitionCount: 0
            )
        case .hard:
            return ReviewSchedule(
                intervalDays: max(1, current.intervalDays + 1),
                easeFactor: adjustedEaseFactor(current.easeFactor, by: -0.15),
                repetitionCount: current.repetitionCount + 1
            )
        case .good:
            return ReviewSchedule(
                intervalDays: nextGoodInterval(after: current),
                easeFactor: current.easeFactor,
                repetitionCount: current.repetitionCount + 1
            )
        case .easy:
            return ReviewSchedule(
                intervalDays: nextEasyInterval(after: current),
                easeFactor: adjustedEaseFactor(current.easeFactor, by: 0.15),
                repetitionCount: current.repetitionCount + 1
            )
        }
    }

    private static func adjustedEaseFactor(_ easeFactor: Double, by delta: Double) -> Double {
        max(minimumEaseFactor, easeFactor + delta)
    }

    private static func nextGoodInterval(after current: ReviewSchedule) -> Int {
        switch current.repetitionCount {
        case 0:
            return 1
        case 1:
            return 3
        default:
            return max(1, Int((Double(max(1, current.intervalDays)) * current.easeFactor).rounded()))
        }
    }

    private static func nextEasyInterval(after current: ReviewSchedule) -> Int {
        if current.repetitionCount == 0 {
            return 4
        }

        let scaledInterval = Double(max(1, current.intervalDays)) * (current.easeFactor + 0.3)
        return max(4, Int(scaledInterval.rounded()))
    }
}
