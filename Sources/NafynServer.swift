// Made by Lumaa

import Foundation
import os

/// Executes ``NafynEndpoint``s against a connected ``NafynInstance``.
///
/// `NafynServer` is the single entry point for every Nafyn API call. Create one from a validated
/// instance, optionally log in, then pass any endpoint case to ``send(_:)``:
/// ```swift
/// let instance = try await NafynInstance.connect(to: URL(string: "http://localhost:3000")!)
/// let server = NafynServer(instance: instance)
///
/// let auth: AuthResponse = try await server.send(Auth.login(username: "me", password: "hunter2"))
/// server.authToken = auth.token
///
/// let album: AlbumDetail = try await server.send(Album.get(aid: "b84ee12a-09ef-421b-82de-0441a926375b"))
/// ```
///
/// `NafynServer` is a plain class rather than an `actor`: its two pieces of mutable state
/// (``authToken`` and ``debugLoggingEnabled``) are protected by locks internally, so they can be read
/// and written synchronously without `await`, while every network call remains `async throws`.
public final class NafynServer: Sendable {

	/// The Nafyn server this instance talks to.
	public let instance: NafynInstance

	private let session: URLSession
	private let encoder: JSONEncoder
	private let decoder: JSONDecoder
	private let tokenLock: OSAllocatedUnfairLock<String?>
	private let debugLock: OSAllocatedUnfairLock<Bool>
	private let logger = Logger(subsystem: "com.safyn", category: "network")

	/// The bearer token attached as `Authorization: Bearer <token>` to every request, once set.
	///
	/// Set this after a successful ``Auth`` login/register call. `nil` (the default) sends no
	/// `Authorization` header, which is fine for endpoints that don't require authentication.
	public var authToken: String? {
		get { tokenLock.withLock { $0 } }
		set { tokenLock.withLock { $0 = newValue } }
	}

	/// When `true`, every request and response is logged via `os.Logger` (subsystem `"com.safyn"`, category `"network"`).
	///
	/// Turn this on while debugging a failing request in your app; pair it with ``curlCommand(for:)``
	/// to reproduce the exact same request outside your app.
	public var debugLoggingEnabled: Bool {
		get { debugLock.withLock { $0 } }
		set { debugLock.withLock { $0 = newValue } }
	}

	/// Creates a server that executes requests against `instance`.
	/// - Parameters:
	///   - instance: A validated ``NafynInstance``, from ``NafynInstance/connect(to:session:)``.
	///   - authToken: A previously-obtained session token, if you're restoring a logged-in session.
	///   - session: The `URLSession` to issue requests with. Defaults to `.shared`.
	///   - debugLoggingEnabled: Whether to log requests/responses on creation. Defaults to `false`.
	public init(instance: NafynInstance, authToken: String? = nil, session: URLSession = .shared, debugLoggingEnabled: Bool = false) {
		self.instance = instance
		self.session = session
		self.tokenLock = OSAllocatedUnfairLock(initialState: authToken)
		self.debugLock = OSAllocatedUnfairLock(initialState: debugLoggingEnabled)

		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		self.encoder = encoder

		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		self.decoder = decoder
	}

	/// HTTP methods used by ``NafynEndpoint``s.
	public enum HTTPMethod: String, Sendable {
		case get = "GET"
		case post = "POST"
		case patch = "PATCH"
		case delete = "DELETE"
	}

	// MARK: - Sending requests

	/// Sends `endpoint` and decodes its JSON response as `Response`.
	///
	/// Use this for every endpoint except the raw/binary ones (audio streaming, image serving) — for those, use ``sendRaw(_:)``.
	@discardableResult
	public func send<E: NafynEndpoint, Response: Decodable & Sendable>(_ endpoint: E) async throws -> Response {
		let request = try buildRequest(for: endpoint)
		logRequest(request)
		let (data, response) = try await perform(request)
		try validate(response, data: data)
		do {
			return try decoder.decode(Response.self, from: data)
		} catch {
			throw NafynError.decoding(String(describing: error))
		}
	}

	/// Sends `endpoint` and returns its raw response body, without attempting to decode it as JSON.
	///
	/// Use this for endpoints that return binary data instead of JSON, e.g. `Library.stream(id:token:range:)`
	/// or `Playlist.image(pid:token:)`.
	@discardableResult
	public func sendRaw<E: NafynEndpoint>(_ endpoint: E) async throws -> Data {
		let request = try buildRequest(for: endpoint)
		logRequest(request)
		let (data, response) = try await perform(request)
		try validate(response, data: data)
		return data
	}

	// MARK: - Live download progress

	/// Opens a ``NafynDownloadSocket`` streaming live progress for `requestId`, using this server's
	/// current ``authToken`` and instance host.
	///
	/// - Throws: ``NafynError/unauthenticated`` if ``authToken`` isn't set — the socket requires it as
	///   a query parameter, since a WebSocket handshake can't carry a custom `Authorization` header.
	public func downloadSocket(requestId: String) throws -> NafynDownloadSocket {
		guard let token = authToken else {
			throw NafynError.unauthenticated
		}
		guard var components = URLComponents(url: instance.baseURL, resolvingAgainstBaseURL: false) else {
			throw NafynError.invalidURL
		}
		components.scheme = components.scheme == "https" ? "wss" : "ws"
		components.path += "/ws/downloads"
		components.queryItems = [
			URLQueryItem(name: "requestId", value: requestId),
			URLQueryItem(name: "token", value: token),
		]
		guard let url = components.url else {
			throw NafynError.invalidURL
		}
		return NafynDownloadSocket(url: url)
	}

	// MARK: - Request building

	private func buildRequest<E: NafynEndpoint>(for endpoint: E) throws -> URLRequest {
		guard let url = URL(string: instance.baseURL.absoluteString + endpoint.path) else {
			throw NafynError.invalidURL
		}
		guard var components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
			throw NafynError.invalidURL
		}
		if !endpoint.queries.isEmpty {
			components.queryItems = endpoint.queries
		}
		guard let finalURL = components.url else {
			throw NafynError.invalidURL
		}

		var request = URLRequest(url: finalURL)
		request.httpMethod = (endpoint.methods.first ?? .get).rawValue

		for (key, value) in endpoint.headers {
			request.setValue(value, forHTTPHeaderField: key)
		}
		if let token = authToken {
			request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
		}

		if let multipart = endpoint.multipart {
			let boundary = "Safyn-Boundary-\(UUID().uuidString)"
			request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
			request.httpBody = Self.multipartBody(boundary: boundary, parts: multipart)
		} else if let body = endpoint.body {
			request.setValue("application/json", forHTTPHeaderField: "Content-Type")
			do {
				request.httpBody = try encoder.encode(body)
			} catch {
				throw NafynError.decoding(String(describing: error))
			}
		}

		return request
	}

	/// Builds a `multipart/form-data` body from one or more file/text parts.
	private static func multipartBody(boundary: String, parts: [MultipartPart]) -> Data {
		var body = Data()
		func append(_ string: String) {
			if let chunk = string.data(using: .utf8) {
				body.append(chunk)
			}
		}

		for part in parts {
			append("--\(boundary)\r\n")
			switch part {
				case .file(let fieldName, let filename, let mimeType, let data):
					append("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(filename)\"\r\n")
					append("Content-Type: \(mimeType)\r\n\r\n")
					body.append(data)
					append("\r\n")
				case .text(let fieldName, let value):
					append("Content-Disposition: form-data; name=\"\(fieldName)\"\r\n\r\n")
					append(value)
					append("\r\n")
			}
		}
		append("--\(boundary)--\r\n")

		return body
	}

	// MARK: - Response handling

	private func perform(_ request: URLRequest) async throws -> (Data, URLResponse) {
		do {
			return try await session.data(for: request)
		} catch {
			throw NafynError.transport(error.localizedDescription)
		}
	}

	private func validate(_ response: URLResponse, data: Data) throws {
		guard let httpResponse = response as? HTTPURLResponse else {
			throw NafynError.invalidResponse
		}
		logResponse(httpResponse, data: data)

		guard (200..<300).contains(httpResponse.statusCode) else {
			if let nuxtError = try? decoder.decode(NuxtError.self, from: data) {
				throw NafynError.server(statusCode: httpResponse.statusCode, error: nuxtError)
			}
			throw NafynError.invalidResponse
		}
	}

	// MARK: - Debug logging

	private func logRequest(_ request: URLRequest) {
		guard debugLoggingEnabled else { return }
		logger.debug("→ \(request.httpMethod ?? "GET", privacy: .public) \(request.url?.absoluteString ?? "", privacy: .public)")
	}

	private func logResponse(_ response: HTTPURLResponse, data: Data) {
		guard debugLoggingEnabled else { return }
		logger.debug("← \(response.statusCode, privacy: .public) (\(data.count, privacy: .public) bytes) \(response.url?.absoluteString ?? "", privacy: .public)")
	}
}
