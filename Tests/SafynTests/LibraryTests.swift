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

	@Test("Searching and sorting library tracks")
	func tracksSearchedAndSorted() async throws {
		let server = try await authenticatedServer()
		for sort in LibrarySort.allCases {
			let tracks: PaginatedResponse<MediaRow> = try await server.send(Library.tracks(limit: 5, query: "a", sort: sort))
			#expect(tracks.items.count <= 5)
		}
	}

	@Test("Searching and sorting library albums")
	func albumsSearchedAndSorted() async throws {
		let server = try await authenticatedServer()
		for sort in LibrarySort.allCases {
			let albums: PaginatedResponse<AlbumRow> = try await server.send(Library.albums(limit: 5, query: "a", sort: sort))
			#expect(albums.items.count <= 5)
		}
	}

	@Test("Moving a track to another album")
	func changeAlbum() async throws {
		let server = try await authenticatedServer()
		let row: MediaRow = try await server.send(Library.changeAlbum(id: "some-media-id", albumId: "some-release-group-id"))
		#expect(row.albumId == "some-release-group-id")
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
		#expect(!lyrics.lyrics.isEmpty)
	}

	@Test("Setting a track's lyric offset")
	func lyricsOffset() async throws {
		let server = try await authenticatedServer()
		let offset: LyricsOffset = try await server.send(Library.setLyricsOffset(id: "some-media-id", offsetMs: 200))
		#expect(offset.offsetMs == 200)
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

	@Test("Listing cover options for an unknown album")
	func coverOptions() async throws {
		let server = try await authenticatedServer()
		let response: CoverOptionsResponse = try await server.send(Library.coverOptions(albumId: "b84ee12a-09ef-421b-82de-0441a926375b"))
		#expect(response.options.count >= 0)
	}

	@Test("Listing cover options for one track lists only art that exists")
	func coverOptionsForRecording() async throws {
		let server = try await authenticatedServer()
		let response: CoverOptionsResponse = try await server.send(Library.coverOptionsForRecording(recordingId: "b7d1ba3e-ff23-4eae-acf3-5e0e0a1ea3b8"))
		#expect(response.options.allSatisfy { $0.kind == .release && !$0.url.isEmpty })
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
