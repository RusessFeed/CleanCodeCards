import Foundation

@MainActor
final class CardsViewModel: ObservableObject {
    struct StudySummary: Equatable {
        let totalCards: Int
        let visibleCards: Int
        let favoriteCards: Int
        let topicCount: Int
    }

    @Published var selectedTopic: StudyCard.Topic?
    @Published var searchText = ""
    @Published var showsFavoritesOnly = false

    private let deckStore: DeckStore

    init(deckStore: DeckStore) {
        self.deckStore = deckStore
    }

    var filteredCards: [StudyCard] {
        let topicCards = deckStore.cards(matching: selectedTopic)
        let favoriteCards = showsFavoritesOnly
            ? topicCards.filter { deckStore.isFavorite($0) }
            : topicCards
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else { return favoriteCards }

        return favoriteCards.filter { card in
            card.title.localizedCaseInsensitiveContains(query)
                || card.prompt.localizedCaseInsensitiveContains(query)
                || card.answer.localizedCaseInsensitiveContains(query)
        }
    }

    var studySummary: StudySummary {
        StudySummary(
            totalCards: deckStore.cards.count,
            visibleCards: filteredCards.count,
            favoriteCards: deckStore.favoriteCardIDs.count,
            topicCount: StudyCard.Topic.allCases.count
        )
    }

    var emptyStateMessage: String? {
        guard filteredCards.isEmpty else { return nil }

        if showsFavoritesOnly {
            return "No favorite cards match the current filters."
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            return "No cards match “\(query)”."
        }

        return "No cards are available for this topic yet."
    }

    func isFavorite(_ card: StudyCard) -> Bool {
        deckStore.isFavorite(card)
    }

    func toggleFavorite(_ card: StudyCard) {
        deckStore.toggleFavorite(card)
        objectWillChange.send()
    }
}
