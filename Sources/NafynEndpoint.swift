// Made by Lumaa

import Foundation

/// Represents a single call to the Nafyn API.
///
/// Conforming types are `enum`s grouped by Nafyn's OpenAPI tag (e.g. ``Album``, ``Auth``, ``Playlist``),
/// with one case per operation. ``NafynServer`` executes any `NafynEndpoint` against a connected
/// ``NafynInstance``, assembling the full request URL from the instance's `baseURL` plus this endpoint's
/// `path` and `queries` — endpoints don't know their own host, since a Nafyn server's address varies
/// per instance.
public protocol NafynEndpoint: Sendable {

	/// The API path for this endpoint, always starting with `/` (e.g. `/api/v1/album/123`).
	///
	/// Path parameters are already substituted in; this is the fully-resolved path for the specific case.
	var path: String { get }

	/// The HTTP method(s) usable for this endpoint.
	///
	/// Nafyn endpoints each use exactly one method; this is an array only to mirror the reference
	/// client style this package follows. ``NafynServer`` uses the first element.
	var methods: [NafynServer.HTTPMethod] { get }

	/// URL query items for this endpoint.
	var queries: [URLQueryItem] { get }

	/// Additional HTTP headers for this endpoint, e.g. the `Range` header for byte-range streaming requests.
	var headers: [String: String] { get }

	/// The JSON request body for this endpoint, if any.
	///
	/// Mutually exclusive with ``multipart``: an endpoint should never set both.
	var body: AnyEncodable? { get }

	/// The multipart file upload payload for this endpoint, if any.
	///
	/// Mutually exclusive with ``body``: an endpoint should never set both.
	var multipart: MultipartFile? { get }
}

public extension NafynEndpoint {
	var queries: [URLQueryItem] { [] }
	var headers: [String: String] { [:] }
	var body: AnyEncodable? { nil }
	var multipart: MultipartFile? { nil }
}
