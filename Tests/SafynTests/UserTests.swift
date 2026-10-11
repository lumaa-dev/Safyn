// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("User Endpoints")
struct UserTests {

	@Test("Fetching the authenticated user's own profile")
	func me() async throws {
		let server = try await authenticatedServer()
		let me: NafynUser = try await server.send(User.me)
		#expect(me.username == testUsername)
	}

	@Test("Updating the authenticated user's own profile")
	func updateProfile() async throws {
		let server = try await authenticatedServer()
		let updated: NafynUser = try await server.send(User.updateProfile(displayName: "Safyn Tester", lastFm: .value("safyn-tester")))
		#expect(updated.displayName == "Safyn Tester")
	}

	@Test("Fetching another user's avatar")
	func avatar() async throws {
		let server = try await authenticatedServer()
		let me: NafynUser = try await server.send(User.me)
		let data: Data = try await server.sendRaw(User.avatar(id: me.id))
		#expect(!data.isEmpty)
	}

	@Test("Uploading a new avatar for the authenticated user")
	func setAvatar() async throws {
		let server = try await authenticatedServer()
		let placeholderImage = Data([0x52, 0x49, 0x46, 0x46]) // not a real WebP file, just exercising the upload path
		let updated: NafynUser = try await server.send(User.setAvatar(data: placeholderImage))
		#expect(updated.avatar != nil)
	}

	@Test("Removing the authenticated user's own avatar")
	func deleteAvatar() async throws {
		let server = try await authenticatedServer()
		let updated: NafynUser = try await server.send(User.deleteAvatar)
		#expect(updated.avatar == nil)
	}
}

@Suite("Session & Unity Endpoints")
struct SessionTests {

	@Test("Listing sessions includes the current one")
	func sessions() async throws {
		let server = try await authenticatedServer()
		let sessions: [SessionSummary] = try await server.send(User.sessions)
		#expect(sessions.contains { $0.isCurrent })
	}

	@Test("Unity setting round-trips")
	func unitySettings() async throws {
		let server = try await authenticatedServer()
		let updated: UnitySettings = try await server.send(User.updateUnitySettings(enabled: true))
		#expect(updated.enabled)
	}

	@Test("Command wire format round-trips")
	func commandWire() {
		let command = UnityCommand.seek(93)
		#expect(UnityCommand(action: command.action, payload: command.payload) == command)
	}

	@Test("Unity event decoding")
	func eventDecoding() throws {
		let json = #"{"type":"command","action":"seek","payload":[93]}"#
		let event = try JSONDecoder().decode(UnityEvent.self, from: Data(json.utf8))
		guard case .command(.seek(93)) = event else {
			Issue.record("unexpected \(event)")
			return
		}
	}
}
