// Made by Lumaa

import Foundation

/// A single play event to ingest via `Insights.ingestEvents(events:token:)`.
///
/// Encoded with `snake_case` keys (`event_id`, `track_id`, etc.) — unlike the rest of the API, this
/// schema's wire format matches the ingestion pipeline's own field names.
public struct PlayEventInput: Encodable, Sendable, Hashable {
	/// Client-minted UUID; the idempotency key for this play. Retrying a flush with the same ID is safe.
	public let eventId: String

	/// The Nafyn media ID that was played.
	public let trackId: String

	/// The playlist ID the play started from, if it started from a playlist the user can access.
	public let playlistId: String?

	/// Epoch milliseconds the play started. Rejected if more than 7 days in the past or 5 minutes in the future.
	public let startedAt: Int64

	/// Wall-clock milliseconds actually played, excluding paused time. Clamped to `[0, 86400000]`.
	public let durationMs: Int

	/// Whether playback reached the end of the file.
	public let completed: Bool?

	/// Where playback was started from.
	public let source: PlayEventSource

	public init(eventId: String, trackId: String, playlistId: String? = nil, startedAt: Int64, durationMs: Int, completed: Bool? = nil, source: PlayEventSource) {
		self.eventId = eventId
		self.trackId = trackId
		self.playlistId = playlistId
		self.startedAt = startedAt
		self.durationMs = durationMs
		self.completed = completed
		self.source = source
	}

	private enum CodingKeys: String, CodingKey {
		case eventId = "event_id"
		case trackId = "track_id"
		case playlistId = "playlist_id"
		case startedAt = "started_at"
		case durationMs = "duration_ms"
		case completed
		case source
	}
}
