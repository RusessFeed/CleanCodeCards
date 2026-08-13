import Foundation

@MainActor
final class QuizViewModel: ObservableObject {
    @Published private(set) var currentIndex = 0
    @Published private(set) var correctAnswers = 0
    @Published private(set) var answeredCardIDs: Set<UUID> = []

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

    func markCurrentAnswer(isCorrect: Bool) {
        guard let card = currentCard, !answeredCardIDs.contains(card.id) else { return }

        answeredCardIDs.insert(card.id)
        if isCorrect { correctAnswers += 1 }

        if currentIndex < cards.count - 1 {
            currentIndex += 1
        }
    }

    func restart() {
        currentIndex = 0
        correctAnswers = 0
        answeredCardIDs = []
    }
}
