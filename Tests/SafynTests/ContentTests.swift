// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Content Endpoints")
struct ContentTests {

	@Test("The privacy notice is public and readable without signing in")
	func privacyNotice() async throws {
		let server = try await connectedServer()
		let notice: JSONValue = try await server.send(Content.privacyNotice(locale: "en"))
		#expect(notice != .null)
	}
}
