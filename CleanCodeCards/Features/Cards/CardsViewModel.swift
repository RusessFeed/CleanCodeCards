import Foundation

@MainActor
final class CardsViewModel: ObservableObject {
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

    func isFavorite(_ card: StudyCard) -> Bool {
        deckStore.isFavorite(card)
    }

    func toggleFavorite(_ card: StudyCard) {
        deckStore.toggleFavorite(card)
        objectWillChange.send()
    }
}
