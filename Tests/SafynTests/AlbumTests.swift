// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Album Endpoints")
struct AlbumTests {

	@Test("Fetching an album by release-group ID returns its tracklist")
	func get() async throws {
		let server = try await authenticatedServer()
		let album: AlbumDetail = try await server.send(Album.get(aid: "b84ee12a-09ef-421b-82de-0441a926375b"))
		#expect(!album.tracks.isEmpty)
	}
}
