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
}
