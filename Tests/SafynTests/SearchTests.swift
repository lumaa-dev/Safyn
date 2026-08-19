// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Search Endpoints")
struct SearchTests {

	@Test("Searching with just a query returns results across all categories")
	func searchAll() async throws {
		let server = try await authenticatedServer()
		let results: SearchResult = try await server.send(Search.search(q: "Daft Punk"))
		#expect(!(results.albums.isEmpty && results.tracks.isEmpty && results.artists.isEmpty))
	}

	@Test("Searching with a filter restricts the result category")
	func searchFiltered() async throws {
		let server = try await authenticatedServer()
		let results: SearchResult = try await server.send(Search.search(q: "Daft Punk", filter: .artist, limit: 5, offset: 0))
		#expect(results.tracks.isEmpty)
		#expect(results.albums.isEmpty)
	}
}
