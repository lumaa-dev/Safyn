// Made by Lumaa

import Foundation

/// A type-erased wrapper around any `Encodable & Sendable` value.
///
/// Used by ``NafynEndpoint/body`` so endpoint cases can carry heterogeneous JSON request bodies
/// without making ``NafynEndpoint`` itself generic.
public struct AnyEncodable: Encodable, Sendable {
	private let _encode: @Sendable (Encoder) throws -> Void

	/// Wraps `value` for type-erased encoding.
	public init<T: Encodable & Sendable>(_ value: T) {
		self._encode = { encoder in
			try value.encode(to: encoder)
		}
	}

	public func encode(to encoder: Encoder) throws {
		try _encode(encoder)
	}
}
