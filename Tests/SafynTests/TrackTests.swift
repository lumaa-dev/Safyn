// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Track Endpoints")
struct TrackTests {

	@Test("Fetching a track by MusicBrainz recording ID")
	func get() async throws {
		let server = try await authenticatedServer()
		let track: TrackDetail = try await server.send(Track.get(tid: "f8ecd693-2c62-4fc0-98f3-e2c8a5f70f6b"))
		#expect(!track.info.title.isEmpty)
	}

	@Test("Fetching a track by ISRC")
	func getByIsrc() async throws {
		let server = try await authenticatedServer()
		let track: TrackDetail = try await server.send(Track.getByIsrc(isrc: "USRC17607839"))
		#expect(!track.info.title.isEmpty)
	}

	@Test("An unknown ISRC with title and artist falls back to a search")
	func getByIsrcFallback() async throws {
		let server = try await authenticatedServer()
		let track: TrackDetail = try await server.send(Track.getByIsrc(isrc: "ZZZZZ0000000", title: "Get Lucky", artist: "Daft Punk"))
		#expect(track.searchFallback == true)
	}

	@Test("An unknown ISRC without a fallback is a 404")
	func getByIsrcNoFallback() async throws {
		let server = try await authenticatedServer()
		await #expect(throws: NafynError.self) {
			let _: TrackDetail = try await server.send(Track.getByIsrc(isrc: "ZZZZZ0000000"))
		}
	}

	@Test("A track exposes inLibrary so duplicate requests can be avoided")
	func getInLibrary() async throws {
		let server = try await authenticatedServer()
		let track: TrackDetail = try await server.send(Track.get(tid: "f8ecd693-2c62-4fc0-98f3-e2c8a5f70f6b"))
		#expect(track.info.inLibrary != nil)
		#expect(track.requested != nil)
	}
}
