import Foundation

@MainActor
final class CardsViewModel: ObservableObject {
    @Published var selectedTopic: StudyCard.Topic?
    @Published var searchText = ""

    private let deckStore: DeckStore

    init(deckStore: DeckStore) {
        self.deckStore = deckStore
    }

    var filteredCards: [StudyCard] {
        let topicCards = deckStore.cards(matching: selectedTopic)
        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !query.isEmpty else { return topicCards }

        return topicCards.filter { card in
            card.title.localizedCaseInsensitiveContains(query)
                || card.prompt.localizedCaseInsensitiveContains(query)
                || card.answer.localizedCaseInsensitiveContains(query)
        }
    }
}
