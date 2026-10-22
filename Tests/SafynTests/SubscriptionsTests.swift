// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Subscriptions Endpoints")
struct SubscriptionsTests {

	@Test("Listing followed upcoming releases")
	func list() async throws {
		let server = try await authenticatedServer()
		let subscriptions: [ReleaseSubscription] = try await server.send(Subscriptions.list)
		#expect(subscriptions.count >= 0)
	}

	@Test("Following an already-released album is refused")
	func createReleased() async throws {
		let server = try await authenticatedServer()
		await #expect(throws: NafynError.self) {
			let _: ReleaseSubscription = try await server.send(Subscriptions.create(id: "b84ee12a-09ef-421b-82de-0441a926375b", type: .album, timezone: "Europe/Paris"))
		}
	}

	@Test("Unfollowing something not followed fails")
	func deleteNotFollowed() async throws {
		let server = try await authenticatedServer()
		await #expect(throws: NafynError.self) {
			_ = try await server.sendRaw(Subscriptions.delete(mbid: "00000000-0000-0000-0000-000000000000"))
		}
	}
}
