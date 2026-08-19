// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Users Endpoints")
struct UsersTests {

	@Test("Listing every user account")
	func all() async throws {
		let server = try await authenticatedServer()
		let users: [NafynUser] = try await server.send(Users.all)
		#expect(!users.isEmpty)
	}

	@Test("Updating another user's account fields")
	func update() async throws {
		let server = try await authenticatedServer()
		let users: [NafynUser] = try await server.send(Users.all)
		guard let target = users.first else {
			Issue.record("No users to update")
			return
		}
		let updated: NafynUser = try await server.send(Users.update(id: target.id, displayName: "Renamed by Safyn"))
		#expect(updated.displayName == "Renamed by Safyn")
	}

	@Test("Uploading an avatar for another user")
	func setAvatar() async throws {
		let server = try await authenticatedServer()
		let users: [NafynUser] = try await server.send(Users.all)
		guard let target = users.first else {
			Issue.record("No users to update")
			return
		}
		let placeholderImage = Data([0x52, 0x49, 0x46, 0x46])
		let updated: NafynUser = try await server.send(Users.setAvatar(id: target.id, data: placeholderImage))
		#expect(updated.avatar != nil)
	}

	@Test("Deleting a user account")
	func delete() async throws {
		let server = try await authenticatedServer()
		let response: RemovedResponse = try await server.send(Users.delete(id: "some-user-id"))
		#expect(response.removed)
	}
}
