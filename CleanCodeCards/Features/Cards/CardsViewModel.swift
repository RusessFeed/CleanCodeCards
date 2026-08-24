import Foundation

@MainActor
final class CardsViewModel: ObservableObject {
    struct StudySummary: Equatable {
        let totalCards: Int
        let visibleCards: Int
        let favoriteCards: Int
        let topicCount: Int
    }

    struct TopicBreakdown: Identifiable, Equatable {
        let topic: StudyCard.Topic
        let cardCount: Int

        var id: StudyCard.Topic { topic }
    }

    struct FocusSuggestion: Equatable {
        let title: String
        let reason: String
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

    var topicBreakdown: [TopicBreakdown] {
        StudyCard.Topic.allCases.map { topic in
            TopicBreakdown(
                topic: topic,
                cardCount: deckStore.cards.filter { $0.topic == topic }.count
            )
        }
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

    var focusSuggestion: FocusSuggestion? {
        if let favoriteCard = filteredCards.first(where: { deckStore.isFavorite($0) }) {
            return FocusSuggestion(
                title: favoriteCard.title,
                reason: "Start with a favorite card while it is top of mind."
            )
        }

        guard let firstCard = filteredCards.first else { return nil }
        return FocusSuggestion(
            title: firstCard.title,
            reason: "A quick warm-up card for the current filters."
        )
    }

    var filterSummaryText: String {
        var filters: [String] = []

        if let selectedTopic {
            filters.append(selectedTopic.rawValue)
        }

        if showsFavoritesOnly {
            filters.append("Favorites")
        }

        let query = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !query.isEmpty {
            filters.append("Search: \(query)")
        }

        return filters.isEmpty ? "Showing all study cards" : filters.joined(separator: " · ")
    }

    func isFavorite(_ card: StudyCard) -> Bool {
        deckStore.isFavorite(card)
    }

    func toggleFavorite(_ card: StudyCard) {
        deckStore.toggleFavorite(card)
        objectWillChange.send()
    }
}
