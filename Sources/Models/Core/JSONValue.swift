// Made by Lumaa

import Foundation

/// An arbitrary JSON value, used where the Nafyn Unity protocol carries untyped data
/// (command arguments, queued track objects).
public enum JSONValue: Codable, Sendable, Hashable {
	case null
	case bool(Bool)
	case number(Double)
	case string(String)
	case array([JSONValue])
	case object([String: JSONValue])

	public init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		if container.decodeNil() {
			self = .null
		} else if let value = try? container.decode(Bool.self) {
			self = .bool(value)
		} else if let value = try? container.decode(Double.self) {
			self = .number(value)
		} else if let value = try? container.decode(String.self) {
			self = .string(value)
		} else if let value = try? container.decode([JSONValue].self) {
			self = .array(value)
		} else {
			self = .object(try container.decode([String: JSONValue].self))
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
			case .null: try container.encodeNil()
			case .bool(let value): try container.encode(value)
			case .number(let value): try container.encode(value)
			case .string(let value): try container.encode(value)
			case .array(let value): try container.encode(value)
			case .object(let value): try container.encode(value)
		}
	}

	/// Decodes this value into a concrete `Decodable` type, e.g. a queued track object.
	public func decode<T: Decodable>(_ type: T.Type = T.self) throws -> T {
		try JSONDecoder().decode(T.self, from: JSONEncoder().encode(self))
	}
}
