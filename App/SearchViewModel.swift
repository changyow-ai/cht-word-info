import Foundation
import Combine

@MainActor
final class SearchViewModel: ObservableObject {
    @Published var query: String = ""
    @Published var searchType: SearchType = .one
    @Published var currentURL: URL = DictURL.homeURL

    func submit() {
        guard let url = DictURL.buildSearchURL(query: query, type: searchType) else { return }
        currentURL = url
    }

    func goHome() {
        currentURL = DictURL.homeURL
    }
}
