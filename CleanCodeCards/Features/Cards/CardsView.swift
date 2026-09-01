import SwiftUI

struct CardsView: View {
    @StateObject var viewModel: CardsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCLayout.large) {
                    HeroHeader(
                        summary: viewModel.studySummary,
                        topicBreakdown: viewModel.topicBreakdown,
                        focusSuggestion: viewModel.focusSuggestion
                    )
                    TopicFilter(
                        selectedTopic: $viewModel.selectedTopic,
                        selectedDifficulty: $viewModel.selectedDifficulty,
                        showsFavoritesOnly: $viewModel.showsFavoritesOnly
                    )
                    SortPicker(sortOrder: $viewModel.sortOrder)
                    FilterSummary(
                        text: "\(viewModel.filterSummaryText) · \(viewModel.sortSummaryText)",
                        showsClearButton: viewModel.hasActiveFilters,
                        onClear: viewModel.clearFilters
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

private struct SortPicker: View {
    @Binding var sortOrder: CardsViewModel.SortOrder

    var body: some View {
        Picker("Sort cards", selection: $sortOrder) {
            ForEach(CardsViewModel.SortOrder.allCases) { order in
                Text(order.rawValue).tag(order)
            }
        }
        .pickerStyle(.segmented)
    }
}

private struct FilterSummary: View {
    let text: String
    let showsClearButton: Bool
    let onClear: () -> Void

    var body: some View {
        HStack(spacing: CCLayout.small) {
            Label(text, systemImage: "line.3.horizontal.decrease.circle")
                .font(.footnote.weight(.medium))
                .foregroundStyle(.secondary)

            Spacer()

            if showsClearButton {
                Button("Clear") {
                    onClear()
                }
                .font(.footnote.weight(.semibold))
                .foregroundStyle(CCColor.accent)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, CCLayout.medium)
        .padding(.vertical, 10)
        .background(CCColor.card, in: Capsule())
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
    let focusSuggestion: CardsViewModel.FocusSuggestion?

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

            if let focusSuggestion {
                FocusSuggestionCard(suggestion: focusSuggestion)
            }

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

private struct FocusSuggestionCard: View {
    let suggestion: CardsViewModel.FocusSuggestion

    var body: some View {
        HStack(alignment: .top, spacing: CCLayout.small) {
            Image(systemName: "sparkles")
                .font(.headline)
                .foregroundStyle(CCColor.accent)

            VStack(alignment: .leading, spacing: 4) {
                Text("Focus next")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(.secondary)
                Text(suggestion.title)
                    .font(.headline)
                Text(suggestion.reason)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CCLayout.medium)
        .background(CCColor.canvas, in: RoundedRectangle(cornerRadius: 18))
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
    @Binding var selectedDifficulty: StudyCard.Difficulty?
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

                ForEach(StudyCard.Difficulty.allCases) { difficulty in
                    TopicChip(
                        title: difficulty.rawValue,
                        systemImage: difficulty.systemImage,
                        isSelected: selectedDifficulty == difficulty
                    ) {
                        selectedDifficulty = difficulty
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
                VStack(alignment: .leading, spacing: 4) {
                    Label(card.topic.rawValue, systemImage: card.topic.systemImage)
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(CCColor.accent)

                    Label(card.difficulty.rawValue, systemImage: card.difficulty.systemImage)
                        .font(.caption2.weight(.semibold))
                        .foregroundStyle(.secondary)
                }

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
