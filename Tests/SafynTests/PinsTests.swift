// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Pins Endpoints")
struct PinsTests {

	@Test("Listing pins")
	func list() async throws {
		let server = try await authenticatedServer()
		let pins: [PinnedItem] = try await server.send(Pins.list)
		#expect(pins.count >= 0)
	}

	@Test("Pinning something that doesn't exist is refused")
	func pinMissing() async throws {
		let server = try await authenticatedServer()
		await #expect(throws: NafynError.self) {
			let _: PinResponse = try await server.send(Pins.pin(kind: .track, refId: "00000000-0000-0000-0000-000000000000"))
		}
	}

	@Test("Unpinning is idempotent")
	func unpinMissing() async throws {
		let server = try await authenticatedServer()
		let response: PinResponse = try await server.send(Pins.unpin(kind: .track, refId: "00000000-0000-0000-0000-000000000000"))
		#expect(response.pinned != true)
	}
}
