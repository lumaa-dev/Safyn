// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Artist Endpoints")
struct ArtistTests {

	@Test("Fetching an artist by MusicBrainz ID returns their discography")
	func get() async throws {
		let server = try await authenticatedServer()
		let artist: ArtistDetail = try await server.send(Artist.get(aid: "056e4f3e-d505-4dad-8ec1-d04f521cbb56"))
		#expect(!artist.name.isEmpty)
	}

	@Test("An artist's discography is laid out by kind, newest first")
	func categories() async throws {
		let server = try await authenticatedServer()
		let artist: ArtistDetail = try await server.send(Artist.get(aid: "6fe07aa5-aeed-4ef0-a30f-1d1e2a9d7ee5"))
		for category in artist.categories {
			let dates = category.releases.compactMap { $0.media.releaseDate }
			#expect(dates == dates.sorted(by: >))
		}
	}

	@Test("Fetching an artist picture")
	func image() async throws {
		let server = try await authenticatedServer()
		let response: ArtistImageResponse = try await server.send(Artist.image(aid: "056e4f3e-d505-4dad-8ec1-d04f521cbb56"))
		#expect(response.image == nil || !response.image!.isEmpty)
	}
}
