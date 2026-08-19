// Made by Lumaa

import Foundation

/// A single progress update pushed by ``NafynDownloadSocket`` over `/ws/downloads`.
public struct DownloadProgressEvent: Decodable, Sendable {
	/// The request this event is for.
	public let requestId: String

	/// The download's current stage.
	///
	/// Reuses ``RequestStatus`` rather than a separate type — the socket never pushes `.waiting`
	/// (that's only ever a `NafynRequest`'s initial state before a worker picks it up), but every
	/// other case matches exactly.
	public let stage: RequestStatus

	/// The track currently being downloaded, if known.
	public let trackTitle: String?

	/// The current track's position within a multi-track (album) request, if applicable.
	public let trackIndex: Int?

	/// The total number of tracks in this request, if applicable.
	public let trackCount: Int?

	/// Bytes downloaded so far for the current track, if known.
	public let bytesDownloaded: Int?

	/// The current track's total size in bytes, if known.
	public let totalBytes: Int?

	/// The current download speed in bytes per second, if known.
	public let speedBytesPerSec: Double?

	/// The estimated time remaining, in seconds.
	///
	/// This is a nested optional on purpose: the outer `Optional` is `nil` when the server omits the
	/// key entirely (no estimate available yet); the inner `Optional` is `nil` when the server sends
	/// an explicit `null`. Most callers can just treat both as "no ETA" via `event.etaSeconds ?? nil`.
	public let etaSeconds: Double??

	/// A human-readable status message, if the server included one.
	public let message: String?

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		self.requestId = try container.decode(String.self, forKey: .requestId)
		self.stage = try container.decode(RequestStatus.self, forKey: .stage)
		self.trackTitle = try container.decodeIfPresent(String.self, forKey: .trackTitle)
		self.trackIndex = try container.decodeIfPresent(Int.self, forKey: .trackIndex)
		self.trackCount = try container.decodeIfPresent(Int.self, forKey: .trackCount)
		self.bytesDownloaded = try container.decodeIfPresent(Int.self, forKey: .bytesDownloaded)
		self.totalBytes = try container.decodeIfPresent(Int.self, forKey: .totalBytes)
		self.speedBytesPerSec = try container.decodeIfPresent(Double.self, forKey: .speedBytesPerSec)
		if container.contains(.etaSeconds) {
			self.etaSeconds = .some(try container.decodeIfPresent(Double.self, forKey: .etaSeconds))
		} else {
			self.etaSeconds = .none
		}
		self.message = try container.decodeIfPresent(String.self, forKey: .message)
	}

	private enum CodingKeys: String, CodingKey {
		case requestId, stage, trackTitle, trackIndex, trackCount, bytesDownloaded, totalBytes, speedBytesPerSec, etaSeconds, message
	}
}
