// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Import Endpoints")
struct ImportTests {

	@Test("Importing a playlist, then reading its progress")
	func createAndGet() async throws {
		let server = try await authenticatedServer()
		let created: PlaylistImport = try await server.send(Import.create(
			tracks: [ImportTrack(isrc: "USQX91300108", title: "Get Lucky", artist: "Daft Punk", duration: 248)],
			source: "apple-music",
			name: "Safyn tests"
		))
		#expect(created.total == 1)

		let fetched: PlaylistImport = try await server.send(Import.get(id: created.id))
		#expect(fetched.id == created.id)
		#expect(fetched.items?.count == 1)
	}

	@Test("Listing imports")
	func all() async throws {
		let server = try await authenticatedServer()
		let page: PaginatedResponse<PlaylistImport> = try await server.send(Import.all(page: 1, limit: 5))
		#expect(page.page == 1)
	}
}
