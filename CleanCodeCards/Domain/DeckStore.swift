import Foundation

final class DeckStore: ObservableObject {
    @Published private(set) var cards: [StudyCard]
    @Published private(set) var favoriteCardIDs: Set<UUID>

    init(cards: [StudyCard] = StudyCard.samples, favoriteCardIDs: Set<UUID> = []) {
        self.cards = cards
        self.favoriteCardIDs = favoriteCardIDs
    }

    func cards(matching topic: StudyCard.Topic?) -> [StudyCard] {
        guard let topic else { return cards }
        return cards.filter { $0.topic == topic }
    }

    func isFavorite(_ card: StudyCard) -> Bool {
        favoriteCardIDs.contains(card.id)
    }

    func toggleFavorite(_ card: StudyCard) {
        if isFavorite(card) {
            favoriteCardIDs.remove(card.id)
        } else {
            favoriteCardIDs.insert(card.id)
        }
    }
}

extension StudyCard {
    static let samples: [StudyCard] = [
        StudyCard(
            topic: .architecture,
            difficulty: .medium,
            title: "MVVM boundaries",
            prompt: "Where should formatting and business rules live in MVVM?",
            answer: "Views render state, view models prepare state and handle UI actions, while business rules belong in domain services or use cases.",
            interviewTip: "Mention testability and small dependency-injected collaborators."
        ),
        StudyCard(
            topic: .swift,
            difficulty: .easy,
            title: "Value semantics",
            prompt: "Why are structs commonly used for app state in SwiftUI?",
            answer: "They make state changes explicit, predictable, and cheap to reason about when SwiftUI recalculates view bodies.",
            interviewTip: "Connect the answer to immutability, copy-on-write collections, and safer concurrency."
        ),
        StudyCard(
            topic: .testing,
            difficulty: .easy,
            title: "Test seams",
            prompt: "How do protocols help unit testing networking or persistence?",
            answer: "A protocol hides the concrete implementation, so tests can inject deterministic fakes without touching real services.",
            interviewTip: "Give a concrete example: Repository protocol + in-memory fake."
        ),
        StudyCard(
            topic: .performance,
            difficulty: .hard,
            title: "List rendering",
            prompt: "What is a common cause of slow SwiftUI lists?",
            answer: "Doing expensive calculations or unstable identity work inside every row render can cause repeated recomputation.",
            interviewTip: "Suggest stable IDs, precomputed view state, and Instruments when guessing is not enough."
        ),
        StudyCard(
            topic: .architecture,
            difficulty: .hard,
            title: "Single responsibility",
            prompt: "How would you refactor a massive view model?",
            answer: "Extract formatting, validation, data access, and navigation decisions into smaller collaborators with clear protocols.",
            interviewTip: "Say that the goal is not more files, it is lower cognitive load."
        ),
        StudyCard(
            topic: .testing,
            difficulty: .medium,
            title: "Meaningful assertions",
            prompt: "What makes a unit test useful rather than decorative?",
            answer: "It verifies observable behavior, has deterministic inputs, and fails with a clear reason when the behavior regresses.",
            interviewTip: "Avoid saying only 'coverage'. Talk about confidence."
        )
    ]
}
