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

@Suite("User Settings, Tokens & Devices")
struct UserSettingsTests {

	@Test("Listing API tokens")
	func apiTokens() async throws {
		let server = try await authenticatedServer()
		let tokens: [ApiTokenSummary] = try await server.send(User.apiTokens)
		#expect(tokens.count >= 0)
	}

	@Test("Reading appearance settings")
	func appearanceSettings() async throws {
		let server = try await authenticatedServer()
		let _: AppearanceSettings = try await server.send(User.appearanceSettings)
	}

	@Test("Updating playback settings round-trips crossfade")
	func playbackSettings() async throws {
		let server = try await authenticatedServer()
		let updated: PlaybackSettings = try await server.send(User.updatePlaybackSettings(crossfadeEnabled: true, crossfadeMs: 3000))
		#expect(updated.crossfadeEnabled)
	}

	@Test("Listing passkeys")
	func passkeys() async throws {
		let server = try await authenticatedServer()
		let passkeys: [PasskeySummary] = try await server.send(User.passkeys)
		#expect(passkeys.count >= 0)
	}

	@Test("Listing registered Apple devices")
	func devices() async throws {
		let server = try await authenticatedServer()
		let devices: [AppleDevice] = try await server.send(User.devices)
		#expect(devices.count >= 0)
	}

	@Test("Listing the user's webhooks")
	func webhooks() async throws {
		let server = try await authenticatedServer()
		let hooks: [WebhookSummary] = try await server.send(User.webhooks)
		#expect(hooks.count >= 0)
	}

	@Test("Exporting account data returns data")
	func exportAccountData() async throws {
		let server = try await authenticatedServer()
		let data = try await server.sendRaw(User.exportAccountData)
		#expect(!data.isEmpty)
	}

	@Test("Reading the Last.fm connection")
	func lastfm() async throws {
		let server = try await authenticatedServer()
		let connection: LastfmConnection = try await server.send(User.lastfm)
		#expect(connection.scrobbling == false || connection.isConnected)
	}

	@Test("Starting a Last.fm connection")
	func connectLastfm() async throws {
		let server = try await authenticatedServer()
		let link: LastfmConnectResponse = try await server.send(User.connectLastfm(client: .app))
		#expect(link.url.host() == "www.last.fm")
	}

	@Test("Pausing Last.fm scrobbling")
	func updateLastfm() async throws {
		let server = try await authenticatedServer()
		let connection: LastfmConnection = try await server.send(User.updateLastfm(scrobbling: false))
		#expect(connection.scrobbling == false)
	}

	@Test("Disconnecting Last.fm")
	func disconnectLastfm() async throws {
		let server = try await authenticatedServer()
		let _: RemovedResponse = try await server.send(User.disconnectLastfm)
	}

	@Test("Reporting Last.fm now playing")
	func lastfmNowPlaying() async throws {
		let server = try await authenticatedServer()
		_ = try await server.sendRaw(User.lastfmNowPlaying(mediaId: "some-media-id"))
	}
}
