// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

@Suite("Nafyn Instance Connection")
struct NafynInstanceTests {

	// These two don't touch the network — they reject before any request is made, so they should
	// always pass, even without a live Nafyn server.

	@Test("Rejects an insecure (http) connection to a public host")
	func rejectsInsecureRemoteURL() async throws {
		let remoteHTTP = URL(string: "http://example.com")!
		await #expect(throws: NafynError.self) {
			_ = try await NafynInstance.connect(appName: "SafynTests", to: remoteHTTP)
		}
	}

	@Test("Rejects a URL with an unsupported scheme")
	func rejectsUnsupportedScheme() async throws {
		let ftp = URL(string: "ftp://192.168.1.10")!
		await #expect(throws: NafynError.self) {
			_ = try await NafynInstance.connect(appName: "SafynTests", to: ftp)
		}
	}

	@Test("Rejects an empty app name")
	func rejectsEmptyAppName() async throws {
		await #expect(throws: NafynError.invalidAppName) {
			_ = try await NafynInstance.connect(appName: "  ", to: testURL)
		}
	}

	// This one needs a live server at `testURL` to actually succeed.

	@Test("Connects to a live local Nafyn server")
	func connectsToLocalServer() async throws {
		let instance = try await NafynInstance.connect(appName: "SafynTests", to: testURL)
		#expect(instance.baseURL.host == testURL.host)
	}
}
