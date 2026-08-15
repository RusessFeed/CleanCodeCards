import SwiftUI

struct CardsView: View {
    @StateObject var viewModel: CardsViewModel

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: CCLayout.large) {
                    HeroHeader()
                    TopicFilter(
                        selectedTopic: $viewModel.selectedTopic,
                        showsFavoritesOnly: $viewModel.showsFavoritesOnly
                    )

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
                .padding(CCLayout.large)
            }
            .background(CCColor.canvas)
            .navigationTitle("Clean Code Cards")
            .searchable(text: $viewModel.searchText, prompt: "Search cards")
        }
    }
}

private struct HeroHeader: View {
    var body: some View {
        VStack(alignment: .leading, spacing: CCLayout.small) {
            Text("Interview-ready iOS thinking")
                .font(.largeTitle.bold())
            Text("Practice architecture, Swift, testing, and performance answers in focused cards.")
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(CCLayout.large)
        .background(CCColor.card, in: RoundedRectangle(cornerRadius: CCLayout.cardRadius))
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
