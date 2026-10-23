// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Library Endpoints")
struct LibraryTests {

	@Test("Listing every track in the authenticated user's library")
	func tracks() async throws {
		let server = try await authenticatedServer()
		let tracks: [MediaRow] = try await server.send(Library.tracks())
		#expect(tracks.count >= 0)
	}

	@Test("Listing library tracks with a limit and offset")
	func tracksPaginated() async throws {
		let server = try await authenticatedServer()
		let firstPage: [MediaRow] = try await server.send(Library.tracks(limit: 2, offset: 0))
		let secondPage: [MediaRow] = try await server.send(Library.tracks(limit: 2, offset: 5))
		#expect(firstPage.count <= 2)
		#expect(secondPage.count <= 2)
	}

	@Test("Listing every album in the authenticated user's library")
	func albums() async throws {
		let server = try await authenticatedServer()
		let albums: [AlbumRow] = try await server.send(Library.albums())
		#expect(albums.count >= 0)
	}

	@Test("Listing library albums with a limit and offset")
	func albumsPaginated() async throws {
		let server = try await authenticatedServer()
		let firstPage: [AlbumRow] = try await server.send(Library.albums(limit: 2, offset: 0))
		let secondPage: [AlbumRow] = try await server.send(Library.albums(limit: 2, offset: 5))
		#expect(firstPage.count <= 2)
		#expect(secondPage.count <= 2)
	}

	@Test("Listing every library entry across every user")
	func all() async throws {
		let server = try await authenticatedServer()
		let entries: PaginatedResponse<LibraryMediaEntry> = try await server.send(Library.all())
		#expect(entries.items.count >= 0)
	}

	@Test("Listing library entries across every user with a page and limit")
	func allPaginated() async throws {
		let server = try await authenticatedServer()
		let firstPage: PaginatedResponse<LibraryMediaEntry> = try await server.send(Library.all(page: 1, limit: 2))
		let secondPage: PaginatedResponse<LibraryMediaEntry> = try await server.send(Library.all(page: 2, limit: 2))
		#expect(firstPage.items.count <= 2)
		#expect(secondPage.items.count <= 2)
	}

	@Test("Fetching lyrics for a library track")
	func lyrics() async throws {
		let server = try await authenticatedServer()
		let lyrics: Lyrics = try await server.send(Library.lyrics(id: "some-media-id"))
		#expect(!lyrics.paragraphs.isEmpty)
	}

	@Test("Streaming a library track's audio")
	func stream() async throws {
		let server = try await authenticatedServer()
		let data: Data = try await server.sendRaw(Library.stream(id: "some-media-id"))
		#expect(!data.isEmpty)
	}

	@Test("Fetching a Cover Art Archive cover through the cache")
	func coverArt() async throws {
		let server = try await authenticatedServer()
		let data: Data = try await server.sendRaw(Library.coverArt(type: .releaseGroup, id: "some-release-group-id", size: .medium))
		#expect(!data.isEmpty)
	}

	@Test("Listing recently played items")
	func recentlyPlayed() async throws {
		let server = try await authenticatedServer()
		let entries: [RecentlyPlayedEntry] = try await server.send(Library.recentlyPlayed)
		#expect(entries.count >= 0)
	}

	@Test("Recording a recently played item")
	func recordRecentlyPlayed() async throws {
		let server = try await authenticatedServer()
		let response: RecordedResponse = try await server.send(Library.recordRecentlyPlayed(type: .track, refId: "some-media-id"))
		#expect(response.recorded)
	}

	@Test("Removing a track from the authenticated user's own library")
	func remove() async throws {
		let server = try await authenticatedServer()
		let response: RemovedWithFileResponse = try await server.send(Library.remove(id: "some-media-id"))
		#expect(response.removed)
	}

	@Test("Removing a track from another user's library")
	func removeForUser() async throws {
		let server = try await authenticatedServer()
		let response: RemovedWithFileResponse = try await server.send(Library.removeForUser(id: "some-media-id", userId: "some-user-id"))
		#expect(response.removed)
	}
}
