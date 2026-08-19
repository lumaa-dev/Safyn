// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Playlist Endpoints")
struct PlaylistTests {

	@Test("Creating a playlist")
	func create() async throws {
		let server = try await authenticatedServer()
		let playlist: PlaylistRow = try await server.send(Playlist.create(title: "Safyn Test Playlist", description: "Created by a Safyn test", privacy: .private))
		#expect(playlist.title == "Safyn Test Playlist")
	}

	@Test("Listing the authenticated user's playlists")
	func list() async throws {
		let server = try await authenticatedServer()
		let playlists: [PlaylistRow] = try await server.send(Playlist.list)
		#expect(playlists.count >= 0)
	}

	@Test("Listing every playlist")
	func all() async throws {
		let server = try await authenticatedServer()
		let playlists: [PlaylistRow] = try await server.send(Playlist.all)
		#expect(playlists.count >= 0)
	}

	@Test("Fetching a playlist's details")
	func get() async throws {
		let server = try await authenticatedServer()
		let detail: PlaylistDetail = try await server.send(Playlist.get(pid: "some-playlist-id"))
		#expect(!detail.playlist.id.isEmpty)
	}

	@Test("Updating a playlist's title, clearing its description, and changing its sort mode")
	func update() async throws {
		let server = try await authenticatedServer()
		let updated: PlaylistRow = try await server.send(Playlist.update(pid: "some-playlist-id", title: "Renamed Playlist", description: .clear, sortMode: .title))
		#expect(updated.title == "Renamed Playlist")
	}

	@Test("Adding tracks to a playlist")
	func addTracks() async throws {
		let server = try await authenticatedServer()
		let entries: [PlaylistEntryRow] = try await server.send(Playlist.addTracks(pid: "some-playlist-id", mediaIds: ["some-media-id"]))
		#expect(!entries.isEmpty)
	}

	@Test("Removing a track from a playlist")
	func removeTrack() async throws {
		let server = try await authenticatedServer()
		let response: RemovedResponse = try await server.send(Playlist.removeTrack(pid: "some-playlist-id", eid: "some-entry-id"))
		#expect(response.removed)
	}

	@Test("Reordering a playlist's entries")
	func reorder() async throws {
		let server = try await authenticatedServer()
		let response: ReorderedResponse = try await server.send(Playlist.reorder(pid: "some-playlist-id", order: ["entry-1", "entry-2"]))
		#expect(response.reordered)
	}

	@Test("Inviting a member to a playlist")
	func addMember() async throws {
		let server = try await authenticatedServer()
		let member: PlaylistMemberRow = try await server.send(Playlist.addMember(pid: "some-playlist-id", username: "some-username"))
		#expect(!member.userId.isEmpty)
	}

	@Test("Removing a member from a playlist")
	func removeMember() async throws {
		let server = try await authenticatedServer()
		let response: RemovedResponse = try await server.send(Playlist.removeMember(pid: "some-playlist-id", uid: "some-user-id"))
		#expect(response.removed)
	}

	@Test("Leaving a playlist")
	func leave() async throws {
		let server = try await authenticatedServer()
		let response: RemovedResponse = try await server.send(Playlist.leave(pid: "some-playlist-id"))
		#expect(response.removed)
	}

	@Test("Fetching a playlist's cover image")
	func image() async throws {
		let server = try await authenticatedServer()
		let data: Data = try await server.sendRaw(Playlist.image(pid: "some-playlist-id"))
		#expect(!data.isEmpty)
	}

	@Test("Uploading a playlist's cover image")
	func setImage() async throws {
		let server = try await authenticatedServer()
		let placeholderImage = Data([0x52, 0x49, 0x46, 0x46]) // not a real WebP file, just exercising the upload path
		let updated: PlaylistRow = try await server.send(Playlist.setImage(pid: "some-playlist-id", data: placeholderImage))
		#expect(updated.image != nil)
	}

	@Test("Removing a playlist's cover image")
	func deleteImage() async throws {
		let server = try await authenticatedServer()
		let updated: PlaylistRow = try await server.send(Playlist.deleteImage(pid: "some-playlist-id"))
		#expect(updated.image == nil)
	}

	@Test("Deleting a playlist")
	func delete() async throws {
		let server = try await authenticatedServer()
		let response: RemovedResponse = try await server.send(Playlist.delete(pid: "some-playlist-id"))
		#expect(response.removed)
	}
}
