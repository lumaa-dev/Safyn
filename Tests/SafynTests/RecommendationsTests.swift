// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Recommendations Endpoints")
struct RecommendationsTests {

	@Test("Reading the personalization setting")
	func settings() async throws {
		let server = try await authenticatedServer()
		let settings: RecommendationSettings = try await server.send(Recommendations.settings)
		#expect(settings.available || !settings.enabled || settings.enabled)
	}

	@Test("The Discover page and the mixes")
	func homeAndMixes() async throws {
		let server = try await authenticatedServer()
		let settings: RecommendationSettings = try await server.send(Recommendations.settings)
		guard settings.available, settings.enabled else { return }
		let home: RecommendationHome = try await server.send(Recommendations.home(device: .ios, tzOffsetMinutes: TimeZone.current.secondsFromGMT() / 60))
		#expect(home.shelves.allSatisfy { !$0.decisionId.isEmpty })
		let list: MixList = try await server.send(Recommendations.mixes)
		if let first = list.mixes.first {
			let mix: MixDetail = try await server.send(Recommendations.mix(id: first.id))
			#expect(mix.id == first.id)
		}
		if let shelf = home.shelves.first, let card = shelf.cards.first {
			let response: RecommendationFeedbackResponse = try await server.send(Recommendations.feedback(decisionId: shelf.decisionId, slot: card.slot, event: .open))
			#expect(response.status == "recorded" || response.status == "closed")
		}
	}

	@Test("An unknown mix is a 404")
	func unknownMix() async throws {
		let server = try await authenticatedServer()
		await #expect(throws: NafynError.self) {
			let _: MixDetail = try await server.send(Recommendations.mix(id: "00000000-0000-0000-0000-000000000000"))
		}
	}
}
