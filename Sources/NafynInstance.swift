// Made by Lumaa

import Foundation

/// A validated connection to a specific Nafyn server.
///
/// Create one with ``connect(appName:to:session:)``, then pass it to ``NafynServer`` to actually call endpoints:
/// ```swift
/// let instance = try await NafynInstance.connect(appName: "MyApp", to: URL(string: "http://localhost:3000")!)
/// let server = NafynServer(instance: instance)
/// ```
public struct NafynInstance: Sendable, Equatable {

	/// The name of the app using Safyn, sent as the `User-Agent` header of every request to this server.
	///
	/// Set once in ``connect(appName:to:session:)`` and immutable for the lifetime of the instance. The
	/// server shows it as the device label in the user's sessions (see ``SessionSummary/deviceLabel``).
	public let appName: String

	/// The server's base URL, normalized without a trailing slash.
	public let baseURL: URL

	/// The server's unique identifier, reported by its `/api/_nafyn` health check.
	public let serverId: UUID

	/// The server's reported date at the time of validation.
	public let serverDate: Date

	/// Validates that `url` points to a reachable Nafyn server and returns a connected instance.
	///
	/// Plain `http://` is only allowed against local/private hosts (`localhost`, loopback addresses,
	/// RFC 1918 private ranges, and `.local` mDNS hosts) since Nafyn is typically self-hosted on a LAN;
	/// any other host must use `https://`.
	///
	/// - Parameters:
	///   - appName: The name of your app, sent as the `User-Agent` of every request made through this instance.
	///     Mandatory, and can't be changed afterwards. Leading/trailing whitespace is trimmed.
	///   - url: The Nafyn server's base URL, e.g. `http://192.168.1.138:3000` or `https://music.example.com`.
	///   - session: The `URLSession` to validate with. Defaults to `.shared`.
	/// - Throws: ``NafynError/invalidAppName`` if `appName` is empty,
	///   ``NafynError/insecureConnection(host:)`` if `url` uses `http` on a non-local host,
	///   ``NafynError/notNafynServer(url:)`` if the server doesn't identify itself as Nafyn,
	///   ``NafynError/transport(_:)``/``NafynError/invalidResponse``/``NafynError/decoding(_:)`` for network/parsing failures.
	public static func connect(appName: String, to url: URL, session: URLSession = .shared) async throws -> NafynInstance {
		let appName = appName.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !appName.isEmpty else {
			throw NafynError.invalidAppName
		}
		guard let scheme = url.scheme, let host = url.host, !host.isEmpty else {
			throw NafynError.invalidURL
		}
		guard scheme == "http" || scheme == "https" else {
			throw NafynError.invalidURL
		}
		if scheme == "http" && !isLocalHost(host) {
			throw NafynError.insecureConnection(host: host)
		}

		let baseURL = normalize(url)
		guard let pingURL = URL(string: "/api/_nafyn", relativeTo: baseURL)?.absoluteURL else {
			throw NafynError.invalidURL
		}

		let data: Data
		let response: URLResponse
		do {
			var pingRequest = URLRequest(url: pingURL)
			pingRequest.setValue(appName, forHTTPHeaderField: "User-Agent")
			(data, response) = try await session.data(for: pingRequest)
		} catch {
			throw NafynError.transport(error.localizedDescription)
		}

		guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
			throw NafynError.notNafynServer(url: baseURL)
		}

		let ping: NafynPingResponse
		do {
			ping = try JSONDecoder().decode(NafynPingResponse.self, from: data)
		} catch {
			throw NafynError.decoding(String(describing: error))
		}
		guard ping.nafyn else {
			throw NafynError.notNafynServer(url: baseURL)
		}

		return NafynInstance(
			appName: appName,
			baseURL: baseURL,
			serverId: ping.response.id,
			serverDate: Date(timeIntervalSince1970: TimeInterval(ping.response.date))
		)
	}

	/// Whether `host` is allowed to be reached over plain `http`.
	///
	/// Covers loopback (`localhost`, `127.0.0.1`, `::1`), RFC 1918 private ranges
	/// (`10.0.0.0/8`, `172.16.0.0/12`, `192.168.0.0/16`), and `.local` mDNS hosts.
	private static func isLocalHost(_ host: String) -> Bool {
		let host = host.lowercased()
		if host == "localhost" || host == "127.0.0.1" || host == "::1" {
			return true
		}
		if host.hasSuffix(".local") {
			return true
		}
		if host.hasPrefix("10.") || host.hasPrefix("192.168.") {
			return true
		}
		if host.hasPrefix("172.") {
			let components = host.split(separator: ".")
			if components.count >= 2, let secondOctet = Int(components[1]), (16...31).contains(secondOctet) {
				return true
			}
		}
		return false
	}

	/// Strips a trailing slash from `url`, if present, so path concatenation never produces a double slash.
	private static func normalize(_ url: URL) -> URL {
		var absoluteString = url.absoluteString
		if absoluteString.hasSuffix("/") {
			absoluteString.removeLast()
		}
		return URL(string: absoluteString) ?? url
	}
}
