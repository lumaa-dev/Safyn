// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Request Endpoints")
struct RequestTests {

	@Test("Creating a download request for a track")
	func create() async throws {
		let server = try await authenticatedServer()
		let request: NafynRequest = try await server.send(Request.create(id: "f8ecd693-2c62-4fc0-98f3-e2c8a5f70f6b", type: .track))
		#expect(request.status == .waiting || request.status == .searching)
	}

	@Test("Fetching a request by ID")
	func get() async throws {
		let server = try await authenticatedServer()
		let request: NafynRequest = try await server.send(Request.get(id: "some-request-id"))
		#expect(!request.id.isEmpty)
	}

	@Test("Updating a request's status")
	func updateStatus() async throws {
		let server = try await authenticatedServer()
		let request: NafynRequest = try await server.send(Request.updateStatus(requestId: "some-request-id", status: .completed))
		#expect(request.status == .completed)
	}

	@Test("Listing every download request")
	func all() async throws {
		let server = try await authenticatedServer()
		let requests: [NafynRequest] = try await server.send(Request.all())
		#expect(requests.count >= 0)
	}

	@Test("Listing download requests with a limit and offset")
	func allPaginated() async throws {
		let server = try await authenticatedServer()
		let firstPage: [NafynRequest] = try await server.send(Request.all(limit: 2, offset: 0))
		let secondPage: [NafynRequest] = try await server.send(Request.all(limit: 2, offset: 2))
		#expect(firstPage.count <= 2)
		#expect(secondPage.count <= 2)
	}

	@Test("Listing download requests with status filters")
	func allFiltered() async throws {
		let server = try await authenticatedServer()
		let requests: [NafynRequest] = try await server.send(Request.all(succeeded: false, failed: false))
		#expect(!requests.contains { $0.status == .completed || $0.status == .failed })
	}
}
