// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Insights Endpoints")
struct InsightsTests {

	@Test("Reading insights settings")
	func settings() async throws {
		let server = try await authenticatedServer()
		let _: InsightsSettings = try await server.send(Insights.settings)
	}

	@Test("Fetching this month's insights")
	func monthly() async throws {
		let server = try await authenticatedServer()
		let _: MonthlyInsights = try await server.send(Insights.monthly())
	}

	@Test("Fetching this week's insights")
	func weekly() async throws {
		let server = try await authenticatedServer()
		let _: WeeklyInsights = try await server.send(Insights.weekly())
	}

	@Test("Fetching this year's insights")
	func yearly() async throws {
		let server = try await authenticatedServer()
		let _: YearlyInsights = try await server.send(Insights.yearly())
	}

	@Test("Fetching hourly listening distribution")
	func hourly() async throws {
		let server = try await authenticatedServer()
		let hours: [HourPoint] = try await server.send(Insights.hourly())
		#expect(hours.count >= 0)
	}

	@Test("Exporting listening history returns data")
	func export() async throws {
		let server = try await authenticatedServer()
		let data = try await server.sendRaw(Insights.export)
		#expect(!data.isEmpty)
	}
}
