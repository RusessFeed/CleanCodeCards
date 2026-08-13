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

    let id: UUID
    let topic: Topic
    let title: String
    let prompt: String
    let answer: String
    let interviewTip: String

    init(
        id: UUID = UUID(),
        topic: Topic,
        title: String,
        prompt: String,
        answer: String,
        interviewTip: String
    ) {
        self.id = id
        self.topic = topic
        self.title = title
        self.prompt = prompt
        self.answer = answer
        self.interviewTip = interviewTip
    }
}
