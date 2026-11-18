// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/recommendations` path — personalized mixes and the Discover page.
///
/// Personalization is on by default and each user can turn it off (``Recommendations/updateSettings(enabled:)``):
/// every other endpoint then answers 403. A server with the recommender switched off answers 404.
public enum Recommendations: NafynEndpoint {

	/// The caller's Discover page: shelves (rows) and their cards, ranked by the server's contextual bandit.
	///
	/// Every call is a new ranking decision. Report what the person does with a card through
	/// ``feedback(decisionId:slot:event:msPlayed:)`` with the shelf's ``RecommendationShelf/decisionId`` and the
	/// card's ``RecommendationCard/slot``.
	///
	/// Returns ``RecommendationHome``.
	/// - Parameters:
	///   - device: The client's device class, part of the ranking context.
	///   - tzOffsetMinutes: Minutes to add to UTC to reach the client's local time (`TimeZone.current.secondsFromGMT() / 60`).
	case home(device: RecommendationDevice = .ios, tzOffsetMinutes: Int)

	/// What the person did with a card, within 30 minutes of the page being served.
	///
	/// `.open` when a card is opened, `.play` when a listen started from it ends (with how long it lasted),
	/// `.preview` when a suggestion's preview was listened to, `.request` when a suggestion was requested.
	///
	/// Returns ``RecommendationFeedbackResponse``.
	case feedback(decisionId: String, slot: Int, event: RecommendationFeedbackEvent, msPlayed: Int = 0)

	/// The caller's mixes ("Made For You").
	///
	/// Returns ``MixList``.
	case mixes

	/// One mix, in listening order.
	///
	/// Returns ``MixDetail``.
	case mix(id: String)

	/// Rebuild the caller's mixes now, in the background (at most once every 10 minutes, else 429).
	///
	/// Returns ``MixRefreshResponse`` (HTTP 202). Follow ``MixList/refreshing``.
	case refreshMixes

	/// Whether the caller's personalized recommendations are on.
	///
	/// Returns ``RecommendationSettings``.
	case settings

	/// Turn the caller's personalized recommendations on or off. Off deletes their mixes and ranking history.
	///
	/// Returns ``RecommendationSettings``.
	case updateSettings(enabled: Bool)

	/// The bandit models and their offline evaluation reports. Requires `ADMIN`.
	///
	/// Returns `[`` RecommendationModel``]`.
	case models

	public var path: String {
		switch self {
			case .home: return "/api/v1/recommendations/home"
			case .feedback: return "/api/v1/recommendations/feedback"
			case .mixes: return "/api/v1/recommendations/mixes"
			case .mix(let id): return "/api/v1/recommendations/mixes/\(id)"
			case .refreshMixes: return "/api/v1/recommendations/mixes/refresh"
			case .settings, .updateSettings: return "/api/v1/recommendations/settings"
			case .models: return "/api/v1/recommendations/models"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .feedback, .refreshMixes: return [.post]
			case .updateSettings: return [.patch]
			default: return [.get]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .home(let device, let tz):
				return [URLQueryItem(name: "device", value: device.rawValue), URLQueryItem(name: "tz", value: String(tz))]
			default:
				return []
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .feedback(let decisionId, let slot, let event, let msPlayed):
				return AnyEncodable(RecommendationFeedbackRequest(decisionId: decisionId, slot: slot, event: event, msPlayed: max(0, msPlayed)))
			case .updateSettings(let enabled):
				return AnyEncodable(RecommendationSettingsRequest(enabled: enabled))
			default:
				return nil
		}
	}
}

struct RecommendationFeedbackRequest: Encodable, Sendable {
	let decisionId: String
	let slot: Int
	let event: RecommendationFeedbackEvent
	let msPlayed: Int
}

struct RecommendationSettingsRequest: Encodable, Sendable {
	let enabled: Bool
}
