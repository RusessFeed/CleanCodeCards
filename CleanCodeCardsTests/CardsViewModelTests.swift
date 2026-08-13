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
}
