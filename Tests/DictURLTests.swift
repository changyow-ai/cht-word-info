import XCTest
@testable import MiniMoeDict

final class DictURLTests: XCTestCase {

    func testBuildSearchURLForSingleCharacter() throws {
        let url = try XCTUnwrap(DictURL.buildSearchURL(query: "我", type: .one))
        let comps = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))

        XCTAssertEqual(url.host, "dict.mini.moe.edu.tw")
        XCTAssertEqual(url.path, "/SearchIndex/searchResult")
        XCTAssertEqual(queryValue(comps, "searchType"), "one")
        XCTAssertEqual(queryValue(comps, "dictSearchField"), "我")

        // Confirm percent-encoding when serialised
        let encoded = url.absoluteString
        XCTAssertTrue(encoded.contains("dictSearchField=%E6%88%91"), "Expected URL to be percent-encoded, got: \(encoded)")
    }

    func testBuildSearchURLForWord() throws {
        let url = try XCTUnwrap(DictURL.buildSearchURL(query: "字典", type: .more))
        let comps = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(queryValue(comps, "searchType"), "more")
        XCTAssertEqual(queryValue(comps, "dictSearchField"), "字典")
    }

    func testBuildSearchURLTrimsWhitespace() throws {
        let url = try XCTUnwrap(DictURL.buildSearchURL(query: "  我  ", type: .one))
        let comps = try XCTUnwrap(URLComponents(url: url, resolvingAgainstBaseURL: false))
        XCTAssertEqual(queryValue(comps, "dictSearchField"), "我")
    }

    func testBuildSearchURLRejectsEmpty() {
        XCTAssertNil(DictURL.buildSearchURL(query: "", type: .one))
        XCTAssertNil(DictURL.buildSearchURL(query: "   ", type: .one))
    }

    func testIsAllowedHost() {
        XCTAssertTrue(DictURL.isAllowed(URL(string: "https://dict.mini.moe.edu.tw/")!))
        XCTAssertTrue(DictURL.isAllowed(URL(string: "https://dict.mini.moe.edu.tw/SearchIndex/searchResult?x=1")!))
        XCTAssertFalse(DictURL.isAllowed(URL(string: "https://moe.edu.tw/")!))
        XCTAssertFalse(DictURL.isAllowed(URL(string: "https://www.dict.mini.moe.edu.tw/")!))
        XCTAssertFalse(DictURL.isAllowed(URL(string: "https://example.com/")!))
        XCTAssertFalse(DictURL.isAllowed(nil))
    }

    private func queryValue(_ comps: URLComponents, _ name: String) -> String? {
        comps.queryItems?.first(where: { $0.name == name })?.value
    }
}
