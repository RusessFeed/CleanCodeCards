import XCTest
@testable import CleanCodeCards

final class SpacedRepetitionEngineTests: XCTestCase {
    func testInitialScheduleStartsWithTodayReview() {
        let schedule = SpacedRepetitionEngine.initial

        XCTAssertEqual(schedule.intervalDays, 0)
        XCTAssertEqual(schedule.easeFactor, 2.5)
        XCTAssertEqual(schedule.repetitionCount, 0)
        XCTAssertEqual(schedule.summaryText, "Review today")
    }

    func testAgainRatingResetsRepetitionAndLowersEaseFactor() {
        let current = ReviewSchedule(intervalDays: 8, easeFactor: 2.5, repetitionCount: 3)

        let next = SpacedRepetitionEngine.nextSchedule(after: current, rating: .again)

        XCTAssertEqual(next.intervalDays, 1)
        XCTAssertEqual(next.easeFactor, 2.25)
        XCTAssertEqual(next.repetitionCount, 0)
    }

    func testEaseFactorNeverDropsBelowMinimum() {
        let current = ReviewSchedule(intervalDays: 4, easeFactor: 1.35, repetitionCount: 2)

        let next = SpacedRepetitionEngine.nextSchedule(after: current, rating: .again)

        XCTAssertEqual(next.easeFactor, SpacedRepetitionEngine.minimumEaseFactor)
    }

    func testGoodRatingBuildsStableIntervals() {
        let first = SpacedRepetitionEngine.nextSchedule(after: .init(intervalDays: 0, easeFactor: 2.5, repetitionCount: 0), rating: .good)
        let second = SpacedRepetitionEngine.nextSchedule(after: first, rating: .good)
        let third = SpacedRepetitionEngine.nextSchedule(after: second, rating: .good)

        XCTAssertEqual(first.intervalDays, 1)
        XCTAssertEqual(second.intervalDays, 3)
        XCTAssertEqual(third.intervalDays, 8)
        XCTAssertEqual(third.repetitionCount, 3)
    }

    func testEasyRatingIncreasesIntervalAndEaseFactor() {
        let current = ReviewSchedule(intervalDays: 3, easeFactor: 2.5, repetitionCount: 2)

        let next = SpacedRepetitionEngine.nextSchedule(after: current, rating: .easy)

        XCTAssertEqual(next.intervalDays, 8)
        XCTAssertEqual(next.easeFactor, 2.65)
        XCTAssertEqual(next.repetitionCount, 3)
        XCTAssertEqual(next.summaryText, "Review in 8 days")
    }
}
