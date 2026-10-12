// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/privacy` path.
public enum Content: NafynEndpoint {

	/// The privacy notice document for a locale, as parsed markdown. Public — the notice has to be
	/// readable before an account exists. Falls back to the English document when the requested locale
	/// has no translation.
	///
	/// Returns an untyped ``JSONValue``, or `null` when no notice could be found at all — send this
	/// with ``NafynServer/send(_:)``.
	/// - Parameter locale: Two-letter locale code. Anything else is treated as `en`.
	case privacyNotice(locale: String? = nil)

	public var path: String {
		"/api/v1/privacy"
	}

	public var methods: [NafynServer.HTTPMethod] {
		[.get]
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .privacyNotice(let locale):
				guard let locale else { return [] }
				return [URLQueryItem(name: "locale", value: locale)]
		}
	}
}
