// Made by Lumaa

import Foundation
@testable import Safyn

/// The Nafyn server used by every live-network test in this suite.
///
/// Point this at a real, running Nafyn server to exercise these tests — until then, every test that
/// needs a network round-trip will fail to connect, which is expected (see the package's README).
let testURL = URL(string: "http://localhost:3000/")!

/// Credentials for a test account on `testURL`. Replace with a real account once you have a server running.
let testUsername = "safyn-test"
let testPassword = "change-me"

/// Connects to `testURL` without authenticating.
func connectedServer() async throws -> NafynServer {
	let instance = try await NafynInstance.connect(appName: "SafynTests", to: testURL)
	return NafynServer(instance: instance)
}

/// Connects to `testURL` and logs in with `testUsername`/`testPassword`.
func authenticatedServer() async throws -> NafynServer {
	let server = try await connectedServer()
	let auth: AuthResponse = try await server.send(Auth.login(username: testUsername, password: testPassword))
	server.authToken = auth.token
	return server
}
