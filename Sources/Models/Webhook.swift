// Made by Lumaa

import Foundation

/// The service a webhook delivers to, from ``WebhookSummary/format``.
public enum WebhookFormat: String, Codable, Sendable, Hashable {
	/// Detect the service from the URL. Only valid when creating or editing a webhook.
	case auto
	case discord
	case slack
	case ntfy
	case gotify

	/// A generic JSON payload.
	case json
}

/// An event a webhook can subscribe to.
public enum WebhookEvent: String, Codable, Sendable, Hashable {
	case requestCreated = "request.created"
	case requestAccepted = "request.accepted"
	case requestDenied = "request.denied"
	case requestCompleted = "request.completed"
	case requestFailed = "request.failed"
	case releaseOut = "release.out"
}

/// A webhook, either personal (`User.webhooks`) or instance-wide (`Settings.webhooks`).
///
/// The full URL is a secret and is never returned — only its scheme and host, in ``urlPreview``.
public struct WebhookSummary: Codable, Sendable, Hashable, Identifiable {
	/// The webhook's ID.
	public let id: String

	/// `true` for an instance webhook, `false` for a personal one.
	public let global: Bool

	/// The webhook's name.
	public let name: String

	/// The service it delivers to.
	public let format: WebhookFormat

	/// Scheme and host of the webhook's URL only.
	public let urlPreview: String

	/// The events it subscribes to, or `nil` for every event.
	public let events: [WebhookEvent]?

	/// Whether the webhook is enabled.
	public let enabled: Bool

	/// Consecutive failed deliveries. The webhook is disabled at 10.
	public let failureCount: Int

	/// The last delivery error, if any.
	public let lastError: String?

	/// When the last delivery succeeded, as a Unix timestamp in milliseconds, if one has.
	public let lastDeliveredAt: Int64?

	/// When the webhook was created, as a Unix timestamp in milliseconds.
	public let createdAt: Int64

	public init(id: String, global: Bool, name: String, format: WebhookFormat, urlPreview: String, events: [WebhookEvent]?, enabled: Bool, failureCount: Int, lastError: String?, lastDeliveredAt: Int64?, createdAt: Int64) {
		self.id = id
		self.global = global
		self.name = name
		self.format = format
		self.urlPreview = urlPreview
		self.events = events
		self.enabled = enabled
		self.failureCount = failureCount
		self.lastError = lastError
		self.lastDeliveredAt = lastDeliveredAt
		self.createdAt = createdAt
	}

	/// `lastDeliveredAt` converted to a `Date`, if a delivery has succeeded.
	public var lastDeliveredAtDate: Date? {
		lastDeliveredAt.map { Date(timeIntervalSince1970: TimeInterval($0) / 1000) }
	}

	/// `createdAt` converted to a `Date`.
	public var createdAtDate: Date {
		Date(timeIntervalSince1970: TimeInterval(createdAt) / 1000)
	}
}

/// The result of testing a webhook (`User.testWebhook`/`Settings.testWebhook`).
public struct WebhookTestResponse: Codable, Sendable, Hashable {
	/// Whether the receiving service accepted the sample message.
	public let ok: Bool

	/// What went wrong, if ``ok`` is `false`.
	public let error: String?

	public init(ok: Bool, error: String?) {
		self.ok = ok
		self.error = error
	}
}

/// Shared JSON body for creating and editing webhooks. Every field is optional on the wire.
struct WebhookInput: Encodable, Sendable {
	let name: String?
	let url: String?
	let format: WebhookFormat?
	let events: Patchable<[WebhookEvent]>
	let enabled: Bool?

	private enum CodingKeys: String, CodingKey {
		case name, url, format, events, enabled
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(name, forKey: .name)
		try container.encodeIfPresent(url, forKey: .url)
		try container.encodeIfPresent(format, forKey: .format)
		switch events {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .events)
			case .value(let value): try container.encode(value, forKey: .events)
		}
		try container.encodeIfPresent(enabled, forKey: .enabled)
	}
}
