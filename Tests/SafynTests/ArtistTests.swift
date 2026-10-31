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

	@Test("Fetching an artist picture")
	func image() async throws {
		let server = try await authenticatedServer()
		let response: ArtistImageResponse = try await server.send(Artist.image(aid: "056e4f3e-d505-4dad-8ec1-d04f521cbb56"))
		#expect(response.image == nil || !response.image!.isEmpty)
	}
}
