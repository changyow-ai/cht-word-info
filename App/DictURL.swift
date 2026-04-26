import Foundation

enum SearchType: String, CaseIterable, Identifiable {
    case one          // 單字
    case more         // 詞語

    var id: String { rawValue }

    var displayName: String {
        switch self {
        case .one:  return "單字"
        case .more: return "詞語"
        }
    }
}

enum DictURL {
    static let allowedHost = "dict.mini.moe.edu.tw"
    static let baseURL = URL(string: "https://dict.mini.moe.edu.tw")!

    static var homeURL: URL { baseURL }

    static func buildSearchURL(query: String, type: SearchType) -> URL? {
        let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return nil }

        var comps = URLComponents(
            url: baseURL.appendingPathComponent("SearchIndex/searchResult"),
            resolvingAgainstBaseURL: false
        )
        comps?.queryItems = [
            URLQueryItem(name: "searchType", value: type.rawValue),
            URLQueryItem(name: "dictSearchField", value: trimmed)
        ]
        return comps?.url
    }

    static func isAllowed(_ url: URL?) -> Bool {
        guard let host = url?.host?.lowercased() else { return false }
        return host == allowedHost
    }
}
