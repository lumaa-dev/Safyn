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

	@Test("The ranked list holds every kind, most likely first")
	func rankedList() async throws {
		let server = try await authenticatedServer()
		let results: SearchResult = try await server.send(Search.search(q: "Daft Punk"))
		#expect(results.results.count >= results.artists.count)
		let relevances = results.results.map(\.relevance)
		#expect(relevances.count == results.results.count)
	}

	@Test("Searching with a filter restricts the result category")
	func searchFiltered() async throws {
		let server = try await authenticatedServer()
		let results: SearchResult = try await server.send(Search.search(q: "Daft Punk", filter: .artist, limit: 5, offset: 0))
		#expect(results.tracks.isEmpty)
		#expect(results.albums.isEmpty)
	}

	@Test("Ranked results flag at most one best result")
	func bestResult() async throws {
		let server = try await authenticatedServer()
		let results: SearchResult = try await server.send(Search.search(q: "Daft Punk - Get Lucky", filter: .track))
		#expect(results.tracks.filter { $0.bestResult == true }.count <= 1)
	}

	@Test("Searching with title, artist and ISRC returns ranked tracks")
	func searchWithIdentity() async throws {
		let server = try await authenticatedServer()
		let results: SearchResult = try await server.send(Search.search(q: "Get Lucky", title: "Get Lucky", artist: "Daft Punk", isrc: "USQX91300108", filter: .track))
		#expect(!results.tracks.isEmpty)
	}

	@Test("An ISRC without title and artist is rejected")
	func isrcNeedsTitleAndArtist() async throws {
		let server = try await authenticatedServer()
		await #expect(throws: NafynError.self) {
			let _: SearchResult = try await server.send(Search.search(q: "x", isrc: "USQX91300108"))
		}
	}

	@Test("Listing metadata providers")
	func metadataProviders() async throws {
		let server = try await authenticatedServer()
		let providers: [MetadataProvider] = try await server.send(Search.metadataProviders)
		#expect(providers.count >= 0)
	}
}
