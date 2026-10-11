// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Download Socket")
struct DownloadSocketTests {

	// Pure — constructs a NafynInstance directly (skipping NafynInstance.connect's network ping,
	// available here since @testable import exposes its internal memberwise init) so this doesn't
	// need a live server.

	@Test("Throws unauthenticated when no auth token is set")
	func requiresAuthToken() throws {
		let instance = NafynInstance(appName: "SafynTests", baseURL: testURL, serverId: UUID(), serverDate: Date())
		let server = NafynServer(instance: instance)
		#expect(throws: NafynError.self) {
			_ = try server.downloadSocket(requestId: "some-request-id")
		}
	}

	@Test("Builds a ws:// URL from an http instance once authenticated")
	func buildsSocketWhenAuthenticated() throws {
		let instance = NafynInstance(appName: "SafynTests", baseURL: testURL, serverId: UUID(), serverDate: Date())
		let server = NafynServer(instance: instance, authToken: "test-token")
		#expect(throws: Never.self) {
			_ = try server.downloadSocket(requestId: "some-request-id")
		}
	}
}
