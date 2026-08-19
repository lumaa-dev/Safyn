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
		let response: AuthResponse = try await server.send(Auth.register(username: "safyn-new-user", password: "change-me"))
		#expect(!response.token.isEmpty)
	}
}
