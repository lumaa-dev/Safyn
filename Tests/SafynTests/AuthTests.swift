// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Auth Endpoints")
struct AuthTests {

	@Test("Logging in with valid credentials returns a user and a token")
	func login() async throws {
		let server = try await connectedServer()
		let response: AuthResponse = try await server.send(Auth.login(username: testUsername, password: testPassword))
		#expect(!response.token.isEmpty)
		#expect(response.user.username == testUsername)
	}

	@Test("Registering a new account returns a user and a token")
	func register() async throws {
		let server = try await connectedServer()
		let response: AuthResponse = try await server.send(Auth.register(username: "safyn_new_user", password: "change-me"))
		#expect(!response.token.isEmpty)
	}

	@Test("Logging out revokes the token")
	func logout() async throws {
		let server = try await authenticatedServer()
		_ = try await server.sendRaw(Auth.logout)
		await #expect(throws: NafynError.self) {
			let _: NafynUser = try await server.send(User.me)
		}
	}

	@Test("Requesting passkey login options")
	func passkeyLoginOptions() async throws {
		let server = try await connectedServer()
		let _: JSONValue = try await server.send(Auth.passkeyLoginOptions)
	}
}
