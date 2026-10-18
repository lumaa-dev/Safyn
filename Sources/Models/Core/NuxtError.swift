// Made by Lumaa

import Foundation

/// An error response body returned by the Nafyn server (a Nuxt application).
public struct NuxtError: Codable, Sendable, Equatable, Error {
	/// Always `true`; marks this payload as an error response.
	public let error: Bool

	/// A human-readable message describing what went wrong, if the server provided one.
	public let message: String?

	/// The raw error stack trace, if the server included one.
	///
	/// - Note: The OpenAPI spec does not detail the exact shape of stack frames, so this is decoded
	///   defensively and set to `nil` if it doesn't parse as `[String]`.
	public let stack: [String]?

	/// The HTTP status code of the response this error came from.
	public let statusCode: Int

	/// The standard HTTP status message, e.g. `"Bad Request"`.
	public let statusMessage: String

	/// The request URL that produced this error.
	public let url: String

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.error = try container.decode(Bool.self, forKey: .error)
		self.message = try container.decodeIfPresent(String.self, forKey: .message)
		self.stack = try? container.decodeIfPresent([String].self, forKey: .stack)
		self.statusCode = try container.decode(Int.self, forKey: .statusCode)
		self.statusMessage = try container.decode(String.self, forKey: .statusMessage)
		self.url = try container.decode(String.self, forKey: .url)
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(error, forKey: .error)
		try container.encodeIfPresent(message, forKey: .message)
		try container.encodeIfPresent(stack, forKey: .stack)
		try container.encode(statusCode, forKey: .statusCode)
		try container.encode(statusMessage, forKey: .statusMessage)
		try container.encode(url, forKey: .url)
	}

	private enum CodingKeys: String, CodingKey {
		case error, message, stack, statusCode, statusMessage, url
	}
}
