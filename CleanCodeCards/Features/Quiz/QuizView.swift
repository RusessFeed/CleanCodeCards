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

                if let card = viewModel.currentCard {
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
