import Foundation

struct StudyCard: Identifiable, Equatable {
    enum Topic: String, CaseIterable, Identifiable {
        case architecture = "Architecture"
        case swift = "Swift"
        case testing = "Testing"
        case performance = "Performance"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .architecture: "square.3.layers.3d.down.right"
            case .swift: "swift"
            case .testing: "testtube.2"
            case .performance: "speedometer"
            }
        }
    }

    enum Difficulty: String, CaseIterable, Identifiable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"

        var id: String { rawValue }

        var systemImage: String {
            switch self {
            case .easy: "leaf.fill"
            case .medium: "bolt.fill"
            case .hard: "flame.fill"
            }
        }
    }

    let id: UUID
    let topic: Topic
    let difficulty: Difficulty
    let title: String
    let prompt: String
    let answer: String
    let interviewTip: String

    init(
        id: UUID = UUID(),
        topic: Topic,
        difficulty: Difficulty = .medium,
        title: String,
        prompt: String,
        answer: String,
        interviewTip: String
    ) {
        self.id = id
        self.topic = topic
        self.difficulty = difficulty
        self.title = title
        self.prompt = prompt
        self.answer = answer
        self.interviewTip = interviewTip
    }
}
