// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Settings Endpoints")
struct SettingsTests {

	@Test("Listing active registration tokens")
	func registerTokens() async throws {
		let server = try await authenticatedServer()
		let tokens: [RegisterTokenRow] = try await server.send(Settings.registerTokens)
		#expect(tokens.count >= 0)
	}

	@Test("Creating a new registration token")
	func createRegisterToken() async throws {
		let server = try await authenticatedServer()
		let token: RegisterTokenRow = try await server.send(Settings.createRegisterToken)
		#expect(!token.token.isEmpty)
	}

	@Test("Checking whether open registration is allowed")
	func registrationOpen() async throws {
		let server = try await connectedServer()
		let status: RegistrationOpenResponse = try await server.send(Settings.registrationOpen)
		#expect(status.open == true || status.open == false)
	}

	@Test("Toggling open registration")
	func setRegistrationOpen() async throws {
		let server = try await authenticatedServer()
		let status: RegistrationOpenResponse = try await server.send(Settings.setRegistrationOpen(open: true))
		#expect(status.open == true)
	}

	@Test("Fetching storage usage stats")
	func storage() async throws {
		let server = try await authenticatedServer()
		let info: StorageInfo = try await server.send(Settings.storage)
		#expect(info.totalBytes >= 0)
	}
}
