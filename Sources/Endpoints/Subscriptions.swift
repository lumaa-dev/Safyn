// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/subscriptions` path — following unreleased albums and tracks.
public enum Subscriptions: NafynEndpoint {

	/// List the unreleased albums/tracks the requesting user follows, upcoming first.
	///
	/// Delivered ones stay listed (with ``ReleaseSubscription/notifiedAt`` set) for 30 days.
	/// The spec leaves this response untyped, so it decodes as a bare array.
	///
	/// Returns `[`` ReleaseSubscription``]`.
	case list

	/// Follow an unreleased album or track: at local midnight on its release date (in `timezone`) the
	/// user is notified over APNs and their own webhooks, and Apple devices get a countdown Live Activity
	/// 3 hours before.
	///
	/// Already-released media is refused with a 409 — request it instead. Also a 409 when no release date
	/// is announced; a 404 when not found on MusicBrainz.
	///
	/// Returns ``ReleaseSubscription``.
	/// - Parameters:
	///   - id: MusicBrainz ID (release-group for an album, recording for a track).
	///   - type: Whether `id` is an album or a track.
	///   - timezone: IANA timezone, e.g. `"Europe/Paris"`.
	case create(id: String, type: ReleaseSubscriptionKind, timezone: String)

	/// Stop following an upcoming album/track.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``. Fails with a 404 if not subscribed.
	/// - Parameter mbid: The MusicBrainz ID that was followed.
	case delete(mbid: String)

	public var path: String {
		switch self {
			case .list, .create:
				return "/api/v1/subscriptions"
			case .delete(let mbid):
				return "/api/v1/subscriptions/\(mbid)"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .list:
				return [.get]
			case .create:
				return [.post]
			case .delete:
				return [.delete]
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .create(let id, let type, let timezone):
				return AnyEncodable(CreateReleaseSubscriptionRequest(id: id, type: type, timezone: timezone))
			default:
				return nil
		}
	}
}

struct CreateReleaseSubscriptionRequest: Encodable, Sendable {
	let id: String
	let type: ReleaseSubscriptionKind
	let timezone: String
}
