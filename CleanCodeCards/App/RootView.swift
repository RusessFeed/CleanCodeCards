import SwiftUI

struct RootView: View {
    @EnvironmentObject private var deckStore: DeckStore

    var body: some View {
        TabView {
            CardsView(viewModel: CardsViewModel(deckStore: deckStore))
                .tabItem { Label("Cards", systemImage: "rectangle.stack.fill") }

            QuizView(viewModel: QuizViewModel(cards: deckStore.cards))
                .tabItem { Label("Quiz", systemImage: "checkmark.seal.fill") }
        }
        .tint(CCColor.accent)
    }
}
