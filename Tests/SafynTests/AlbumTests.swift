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

	@Test("An album exposes inLibrary and requested so duplicate requests can be avoided")
	func getRequestState() async throws {
		let server = try await authenticatedServer()
		let album: AlbumDetail = try await server.send(Album.get(aid: "b84ee12a-09ef-421b-82de-0441a926375b"))
		#expect(album.inLibrary == album.tracks.allSatisfy(\.inLibrary))
	}

	@Test("An album lists its releases and shows the one asked for")
	func releases() async throws {
		let server = try await authenticatedServer()
		let album: AlbumDetail = try await server.send(Album.get(aid: "b84ee12a-09ef-421b-82de-0441a926375b"))
		#expect(album.releases.filter(\.selected).count == 1)
		if let other = album.releases.first(where: { !$0.selected }) {
			let shown: AlbumDetail = try await server.send(Album.get(aid: album.id, release: other.id))
			#expect(shown.releaseId == other.id)
			#expect(shown.isDefaultRelease == (other.id == album.releaseId))
		}
	}
}
