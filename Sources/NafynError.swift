// Made by Lumaa

import Foundation

/// Every error ``NafynServer`` and ``NafynInstance`` can throw.
///
/// Every case carries enough detail to diagnose a failed request without attaching a debugger,
/// which is the point: `errorDescription` always surfaces the most actionable information Safyn has.
public enum NafynError: LocalizedError, Sendable, Equatable {
	/// The instance's base URL, or an endpoint's assembled URL, could not be constructed.
	case invalidURL

	/// `http://` was used against a host that isn't local/private, which Safyn refuses to do to avoid leaking credentials in plaintext.
	///
	/// - SeeAlso: ``NafynInstance/connect(to:session:)`` for the exact allowlist (loopback, RFC1918 private ranges, `.local` hosts).
	case insecureConnection(host: String)

	/// The server at this URL responded, but didn't identify itself as a Nafyn server via `/api/_nafyn`.
	case notNafynServer(url: URL)

	/// The server returned a response that isn't a valid HTTP response, or is missing expected data.
	case invalidResponse

	/// The response body could not be decoded into the expected type.
	///
	/// The associated string is a human-readable description of the underlying `DecodingError`.
	case decoding(String)

	/// The server responded with a non-2xx status and a decodable ``NuxtError`` body.
	case server(statusCode: Int, error: NuxtError)

	/// A networking-layer failure occurred (no connection, timeout, etc).
	///
	/// The associated string is a human-readable description of the underlying `URLError`/transport error.
	case transport(String)

	/// The endpoint requires authentication, but no `authToken` is set on the ``NafynServer``.
	case unauthenticated

	public var errorDescription: String? {
		switch self {
			case .invalidURL:
				return "The request URL could not be constructed."
			case .insecureConnection(let host):
				return "Refusing to connect to '\(host)' over plain HTTP; only local/private hosts are allowed to skip HTTPS."
			case .notNafynServer(let url):
				return "'\(url.absoluteString)' did not identify itself as a Nafyn server."
			case .invalidResponse:
				return "The server returned an unexpected or empty response."
			case .decoding(let description):
				return "Failed to decode the server's response: \(description)"
			case .server(let statusCode, let error):
				return "Nafyn server error (\(statusCode)): \(error.message ?? error.statusMessage)"
			case .transport(let description):
				return "Network error: \(description)"
			case .unauthenticated:
				return "This endpoint requires authentication; set NafynServer.authToken first."
		}
	}
}
