import SwiftUI

@main
struct CleanCodeCardsApp: App {
    @StateObject private var deckStore = DeckStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(deckStore)
        }
    }
}
