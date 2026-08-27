import SwiftUI

struct QuizView: View {
    @StateObject var viewModel: QuizViewModel

    var body: some View {
        NavigationStack {
            VStack(spacing: CCLayout.large) {
                HStack {
                    Text(viewModel.progressText)
                    Spacer()
                    Text(viewModel.scoreText)
                }
                .font(.headline.monospacedDigit())

                QuizProgressCard(
                    progress: viewModel.completionProgress,
                    accuracyText: viewModel.accuracyText,
                    answeredCount: viewModel.answeredCount,
                    totalCount: viewModel.cards.count
                )

                if viewModel.isFinished {
                    CompletionCard(scoreText: viewModel.scoreText, accuracyText: viewModel.accuracyText)
                } else if let card = viewModel.currentCard {
                    VStack(alignment: .leading, spacing: CCLayout.medium) {
                        Label(card.topic.rawValue, systemImage: card.topic.systemImage)
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(CCColor.accent)

                        Text(card.prompt)
                            .font(.title2.bold())

                        Text(card.answer)
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, minHeight: 260, alignment: .topLeading)
                    .padding(CCLayout.large)
                    .background(CCColor.card, in: RoundedRectangle(cornerRadius: CCLayout.cardRadius))

                    HStack {
                        Button("Needs practice") {
                            viewModel.markCurrentAnswer(isCorrect: false)
                        }
                        .buttonStyle(.bordered)

                        Button("I knew it") {
                            viewModel.markCurrentAnswer(isCorrect: true)
                        }
                        .buttonStyle(.borderedProminent)
                        .tint(CCColor.positive)
                    }
                }

                Button("Restart quiz") {
                    viewModel.restart()
                }
                .foregroundStyle(CCColor.accent)

                Spacer()
            }
            .padding(CCLayout.large)
            .background(CCColor.canvas)
            .navigationTitle("Quiz")
        }
    }
}

private struct QuizProgressCard: View {
    let progress: Double
    let accuracyText: String
    let answeredCount: Int
    let totalCount: Int

    var body: some View {
        VStack(alignment: .leading, spacing: CCLayout.small) {
            HStack {
                Text("Quiz progress")
                    .font(.subheadline.weight(.semibold))
                Spacer()
                Text("\(answeredCount)/\(totalCount)")
                    .font(.caption.monospacedDigit().weight(.semibold))
                    .foregroundStyle(.secondary)
            }

            ProgressView(value: progress)
                .tint(CCColor.accent)

            Text(accuracyText)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(CCLayout.medium)
        .background(CCColor.card, in: RoundedRectangle(cornerRadius: CCLayout.cardRadius))
    }
}

private struct CompletionCard: View {
    let scoreText: String
    let accuracyText: String

    var body: some View {
        VStack(spacing: CCLayout.medium) {
            Image(systemName: "party.popper.fill")
                .font(.system(size: 48))
                .foregroundStyle(CCColor.positive)
                .symbolRenderingMode(.hierarchical)

            Text("Quiz complete")
                .font(.title2.bold())

            Text("\(scoreText) · \(accuracyText)")
                .font(.headline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, minHeight: 220)
        .padding(CCLayout.large)
        .background(CCColor.card, in: RoundedRectangle(cornerRadius: CCLayout.cardRadius))
    }
}
