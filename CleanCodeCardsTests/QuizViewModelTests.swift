import XCTest
@testable import CleanCodeCards

@MainActor
final class QuizViewModelTests: XCTestCase {
    func testMarkingCorrectAnswerIncrementsScoreAndAdvances() {
        let cards = [
            StudyCard(topic: .swift, title: "One", prompt: "Prompt", answer: "Answer", interviewTip: "Tip"),
            StudyCard(topic: .testing, title: "Two", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        ]
        let viewModel = QuizViewModel(cards: cards)

        viewModel.markCurrentAnswer(isCorrect: true)

        XCTAssertEqual(viewModel.correctAnswers, 1)
        XCTAssertEqual(viewModel.currentCard?.title, "Two")
    }

    func testRestartClearsProgress() {
        let cards = [
            StudyCard(topic: .swift, title: "One", prompt: "Prompt", answer: "Answer", interviewTip: "Tip"),
            StudyCard(topic: .testing, title: "Two", prompt: "Prompt", answer: "Answer", interviewTip: "Tip")
        ]
        let viewModel = QuizViewModel(cards: cards)

        viewModel.markCurrentAnswer(isCorrect: true)
        viewModel.restart()

        XCTAssertEqual(viewModel.correctAnswers, 0)
        XCTAssertEqual(viewModel.currentIndex, 0)
        XCTAssertTrue(viewModel.answeredCardIDs.isEmpty)
    }
}
