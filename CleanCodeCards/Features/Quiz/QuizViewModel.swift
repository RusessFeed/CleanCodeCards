import Foundation

@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var currentIndex = 0
    @Published private(set) var correctAnswers = 0
    @Published private(set) var answeredCardIDs: Set<UUID> = []
    @Published private(set) var isAnswerRevealed = false

    let cards: [StudyCard]

    init(cards: [StudyCard]) {
        self.cards = cards
    }

    var currentCard: StudyCard? {
        guard cards.indices.contains(currentIndex) else { return nil }
        return cards[currentIndex]
    }

    var progressText: String {
        guard !cards.isEmpty else { return "0 / 0" }
        return "\(min(currentIndex + 1, cards.count)) / \(cards.count)"
    }

    var scoreText: String {
        "\(correctAnswers) correct"
    }

    var answeredCount: Int {
        answeredCardIDs.count
    }

    var completionProgress: Double {
        guard !cards.isEmpty else { return 0 }
        return Double(answeredCount) / Double(cards.count)
    }

    var accuracyText: String {
        guard answeredCount > 0 else { return "0% accuracy" }
        let percent = Int((Double(correctAnswers) / Double(answeredCount) * 100).rounded())
        return "\(percent)% accuracy"
    }

    var isFinished: Bool {
        !cards.isEmpty && answeredCount == cards.count
    }

    var canGradeCurrentCard: Bool {
        currentCard != nil && isAnswerRevealed && !isFinished
    }

    func revealAnswer() {
        guard currentCard != nil, !isFinished else { return }
        isAnswerRevealed = true
    }

    func markCurrentAnswer(isCorrect: Bool) {
        guard canGradeCurrentCard,
              let card = currentCard,
              !answeredCardIDs.contains(card.id) else { return }

        answeredCardIDs.insert(card.id)
        if isCorrect { correctAnswers += 1 }

        if currentIndex < cards.count - 1 {
            currentIndex += 1
            isAnswerRevealed = false
        }
    }

    func restart() {
        currentIndex = 0
        correctAnswers = 0
        answeredCardIDs = []
        isAnswerRevealed = false
    }
}
