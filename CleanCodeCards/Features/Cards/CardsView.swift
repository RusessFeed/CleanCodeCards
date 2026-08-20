import SwiftUI

struct CardsView: View {
    @StateObject var viewModel: CardsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCLayout.large) {
                    HeroHeader(
                        summary: viewModel.studySummary,
                        topicBreakdown: viewModel.topicBreakdown
                    )
                    TopicFilter(
                        selectedTopic: $viewModel.selectedTopic,
                        showsFavoritesOnly: $viewModel.showsFavoritesOnly
                    )

                    if let emptyStateMessage = viewModel.emptyStateMessage {
                        EmptyCardsView(message: emptyStateMessage)
                    } else {
                        LazyVStack(spacing: CCLayout.medium) {
                            ForEach(viewModel.filteredCards) { card in
                                StudyCardView(
                                    card: card,
                                    isFavorite: viewModel.isFavorite(card),
                                    onFavoriteToggle: { viewModel.toggleFavorite(card) }
                                )
                            }
                        }
                    }
                }
                .padding(CCLayout.large)
            }
            .background(CCColor.canvas)
            .navigationTitle("Clean Code Cards")
            .searchable(text: $viewModel.searchText, prompt: "Search cards")
        }
    }
}

private struct EmptyCardsView: View {
    let message: String

    var body: some View {
        VStack(spacing: CCLayout.medium) {
            Image(systemName: "magnifyingglass.circle.fill")
                .font(.system(size: 48))
                .foregroundStyle(CCColor.accent)
                .symbolRenderingMode(.hierarchical)

            Text("Nothing to review")
                .font(.title3.bold())

            Text(message)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(CCLayout.large)
        .background(CCColor.card, in: RoundedRectangle(cornerRadius: CCLayout.cardRadius))
    }
}

private struct HeroHeader: View {
    let summary: CardsViewModel.StudySummary
    let topicBreakdown: [CardsViewModel.TopicBreakdown]

    var body: some View {
        VStack(alignment: .leading, spacing: CCLayout.medium) {
            Text("Interview-ready iOS thinking")
                .font(.largeTitle.bold())
            Text("Practice architecture, Swift, testing, and performance answers in focused cards.")
                .foregroundStyle(.secondary)

            HStack(spacing: CCLayout.small) {
                SummaryPill(title: "Cards", value: "\(summary.totalCards)")
                SummaryPill(title: "Visible", value: "\(summary.visibleCards)")
                SummaryPill(title: "Favorites", value: "\(summary.favoriteCards)")
                SummaryPill(title: "Topics", value: "\(summary.topicCount)")
            }
            .padding(.top, CCLayout.small)

            VStack(alignment: .leading, spacing: CCLayout.small) {
                Text("Topic mix")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(.secondary)

                ForEach(topicBreakdown) { item in
                    TopicBreakdownRow(item: item, totalCards: summary.totalCards)
                }
            }
            .padding(.top, CCLayout.small)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CCLayout.large)
        .background(CCColor.card, in: RoundedRectangle(cornerRadius: CCLayout.cardRadius))
    }
}

private struct TopicBreakdownRow: View {
    let item: CardsViewModel.TopicBreakdown
    let totalCards: Int

    private var progress: Double {
        guard totalCards > 0 else { return 0 }
        return Double(item.cardCount) / Double(totalCards)
    }

    var body: some View {
        HStack(spacing: CCLayout.small) {
            Label(item.topic.rawValue, systemImage: item.topic.systemImage)
                .font(.caption.weight(.medium))
                .frame(width: 118, alignment: .leading)

            ProgressView(value: progress)
                .tint(CCColor.accent)

            Text("\(item.cardCount)")
                .font(.caption.monospacedDigit().weight(.semibold))
                .foregroundStyle(.secondary)
                .frame(width: 22, alignment: .trailing)
        }
    }
}

private struct SummaryPill: View {
    let title: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(value)
                .font(.headline.monospacedDigit())
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(CCColor.canvas, in: RoundedRectangle(cornerRadius: 16))
    }
}

private struct TopicFilter: View {
    @Binding var selectedTopic: StudyCard.Topic?
    @Binding var showsFavoritesOnly: Bool

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                TopicChip(title: "Favorites", systemImage: "star.fill", isSelected: showsFavoritesOnly) {
                    showsFavoritesOnly.toggle()
                }

                TopicChip(title: "All", systemImage: "square.grid.2x2", isSelected: selectedTopic == nil) {
                    selectedTopic = nil
                }

                ForEach(StudyCard.Topic.allCases) { topic in
                    TopicChip(title: topic.rawValue, systemImage: topic.systemImage, isSelected: selectedTopic == topic) {
                        selectedTopic = topic
                    }
                }
            }
        }
    }
}

private struct TopicChip: View {
    let title: String
    let systemImage: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Label(title, systemImage: systemImage)
                .font(.subheadline.weight(.semibold))
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .foregroundStyle(isSelected ? .white : CCColor.accent)
                .background(isSelected ? CCColor.accent : CCColor.card, in: Capsule())
        }
    }
}

private struct StudyCardView: View {
    let card: StudyCard
    let isFavorite: Bool
    let onFavoriteToggle: () -> Void
    @State private var isAnswerVisible = false

    var body: some View {
        VStack(alignment: .leading, spacing: CCLayout.medium) {
            HStack {
                Label(card.topic.rawValue, systemImage: card.topic.systemImage)
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(CCColor.accent)

                Spacer()

                Button(action: onFavoriteToggle) {
                    Image(systemName: isFavorite ? "star.fill" : "star")
                        .foregroundStyle(isFavorite ? CCColor.warning : .secondary)
                        .accessibilityLabel(isFavorite ? "Remove from favorites" : "Add to favorites")
                }
                .buttonStyle(.plain)
            }

            Text(card.title)
                .font(.title3.bold())

            Text(card.prompt)
                .foregroundStyle(.secondary)

            if isAnswerVisible {
                Divider()
                Text(card.answer)
                    .font(.body.weight(.medium))
                Text(card.interviewTip)
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }

            Button(isAnswerVisible ? "Hide answer" : "Reveal answer") {
                withAnimation(.spring(duration: 0.25)) {
                    isAnswerVisible.toggle()
                }
            }
            .buttonStyle(.borderedProminent)
            .tint(CCColor.accent)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CCLayout.large)
        .background(CCColor.card, in: RoundedRectangle(cornerRadius: CCLayout.cardRadius))
    }
}
