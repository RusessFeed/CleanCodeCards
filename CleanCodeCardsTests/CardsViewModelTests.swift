import XCTest
@testable import CleanCodeCards

@MainActor
final class CardsViewModelTests: XCTestCase {
    func testFiltersCardsByTopic() {
        let store = DeckStore(cards: [
            StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip"),
            StudyCard(topic: .testing, title: "Fakes", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        ])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.selectedTopic = .swift

        XCTAssertEqual(viewModel.filteredCards.map(\.title), ["Structs"])
    }

    func testSearchMatchesPromptAndAnswer() {
        let store = DeckStore(cards: [
            StudyCard(topic: .swift, title: "Value types", prompt: "Copy behavior", answer: "Predictable state", interviewTip: "Tip"),
            StudyCard(topic: .testing, title: "Mocks", prompt: "Injected fake", answer: "Deterministic", interviewTip: "Tip")
        ])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.searchText = "deterministic"

        XCTAssertEqual(viewModel.filteredCards.map(\.title), ["Mocks"])
    }

    func testFavoritesFilterShowsOnlyMarkedCards() {
        let swiftCard = StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let testingCard = StudyCard(topic: .testing, title: "Fakes", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let store = DeckStore(cards: [swiftCard, testingCard])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.toggleFavorite(testingCard)
        viewModel.showsFavoritesOnly = true

        XCTAssertEqual(viewModel.filteredCards, [testingCard])
        XCTAssertTrue(viewModel.isFavorite(testingCard))
    }

    func testFavoriteFilterCombinesWithTopicFilter() {
        let swiftCard = StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let testingCard = StudyCard(topic: .testing, title: "Fakes", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let store = DeckStore(cards: [swiftCard, testingCard])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.toggleFavorite(testingCard)
        viewModel.selectedTopic = .swift
        viewModel.showsFavoritesOnly = true

        XCTAssertTrue(viewModel.filteredCards.isEmpty)
    }

    func testStudySummaryReflectsVisibleAndFavoriteCards() {
        let swiftCard = StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let testingCard = StudyCard(topic: .testing, title: "Fakes", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let store = DeckStore(cards: [swiftCard, testingCard])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.toggleFavorite(testingCard)
        viewModel.searchText = "structs"

        XCTAssertEqual(
            viewModel.studySummary,
            CardsViewModel.StudySummary(
                totalCards: 2,
                visibleCards: 1,
                favoriteCards: 1,
                topicCount: StudyCard.Topic.allCases.count
            )
        )
    }

    func testTopicBreakdownCountsCardsPerTopic() {
        let cards = [
            StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip"),
            StudyCard(topic: .swift, title: "Actors", prompt: "Prompt", answer: "Answer", interviewTip: "Tip"),
            StudyCard(topic: .testing, title: "Fakes", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        ]
        let viewModel = CardsViewModel(deckStore: DeckStore(cards: cards))

        XCTAssertEqual(
            viewModel.topicBreakdown,
            [
                CardsViewModel.TopicBreakdown(topic: .architecture, cardCount: 0),
                CardsViewModel.TopicBreakdown(topic: .swift, cardCount: 2),
                CardsViewModel.TopicBreakdown(topic: .testing, cardCount: 1),
                CardsViewModel.TopicBreakdown(topic: .performance, cardCount: 0)
            ]
        )
    }

    func testEmptyStateExplainsSearchMiss() {
        let store = DeckStore(cards: [
            StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        ])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.searchText = "Combine"

        XCTAssertEqual(viewModel.emptyStateMessage, "No cards match “Combine”.")
    }

    func testEmptyStateExplainsEmptyFavorites() {
        let store = DeckStore(cards: [
            StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        ])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.showsFavoritesOnly = true

        XCTAssertEqual(viewModel.emptyStateMessage, "No favorite cards match the current filters.")
    }

    func testFocusSuggestionPrefersFavoriteVisibleCard() {
        let swiftCard = StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let testingCard = StudyCard(topic: .testing, title: "Fakes", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let store = DeckStore(cards: [swiftCard, testingCard])
        let viewModel = CardsViewModel(deckStore: store)

        viewModel.toggleFavorite(testingCard)

        XCTAssertEqual(
            viewModel.focusSuggestion,
            CardsViewModel.FocusSuggestion(
                title: "Fakes",
                reason: "Start with a favorite card while it is top of mind."
            )
        )
    }

    func testFocusSuggestionUsesFirstVisibleCardWhenNoFavoriteMatches() {
        let swiftCard = StudyCard(topic: .swift, title: "Structs", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let testingCard = StudyCard(topic: .testing, title: "Fakes", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        let viewModel = CardsViewModel(deckStore: DeckStore(cards: [swiftCard, testingCard]))

        viewModel.selectedTopic = .swift

        XCTAssertEqual(
            viewModel.focusSuggestion,
            CardsViewModel.FocusSuggestion(
                title: "Structs",
                reason: "A quick warm-up card for the current filters."
            )
        )
    }
}
