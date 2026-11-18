// Made by Lumaa

import Foundation

// MARK: - Kinds (forward compatible: a value a newer server adds decodes as `.unknown`)

/// The client's device class, sent with ``Recommendations/home(device:tzOffsetMinutes:)``.
public enum RecommendationDevice: String, Codable, Sendable, Hashable {
	case web
	case ios
	case subsonic
	case other
}

/// What a person did with a Discover card.
public enum RecommendationFeedbackEvent: String, Codable, Sendable, Hashable {
	case open
	case play
	case preview
	case request
}

/// A row of the Discover page.
public enum RecommendationShelfKind: String, Codable, Sendable, Hashable {
	case mixes
	case suggestions
	case jumpBackIn = "jump_back_in"
	case rediscover
	case playlists
	case unknown

	public init(from decoder: Decoder) throws {
		self = RecommendationShelfKind(rawValue: try decoder.singleValueContainer().decode(String.self)) ?? .unknown
	}
}

/// What a Discover card is.
public enum RecommendationItemKind: String, Codable, Sendable, Hashable {
	/// A personalized mix: open it with ``Recommendations/mix(id:)``.
	case mix
	/// A catalogue recording the caller does not have: `refId` is its MusicBrainz recording ID (previewable, requestable).
	case suggestion
	/// A library album: `refId` is the release-group MBID.
	case album
	/// A playlist: `refId` is its ID.
	case playlist
	/// A library track: `refId` is the media ID.
	case track
	case unknown

	public init(from decoder: Decoder) throws {
		self = RecommendationItemKind(rawValue: try decoder.singleValueContainer().decode(String.self)) ?? .unknown
	}
}

/// Why a card is shown. Only true explanations are ever sent.
public enum RecommendationExplanationKind: String, Codable, Sendable, Hashable {
	case none
	/// "Because you listen to `subject`".
	case becauseArtist = "because_artist"
	/// "From your `subject`" (a mix).
	case fromMix = "from_mix"
	case newRelease = "new_release"
	/// Not played in a while.
	case rediscover
	case recentlyPlayed = "recently_played"
	/// Like what was just played.
	case similarToRecent = "similar_to_recent"
	case unknown

	public init(from decoder: Decoder) throws {
		self = RecommendationExplanationKind(rawValue: try decoder.singleValueContainer().decode(String.self)) ?? .unknown
	}
}

/// The facet a mix is named after.
public enum MixLabelKind: String, Codable, Sendable, Hashable {
	/// `value` is a genre name.
	case genre
	/// `value` is a decade, like `1990s`.
	case decade
	/// `value` is `upbeat`, `intense`, `mellow` or `melancholic`.
	case mood
	/// `value` is `night`, `morning`, `afternoon` or `evening`.
	case time
	/// `value` is artist names, comma separated.
	case artist
	case unknown

	public init(from decoder: Decoder) throws {
		self = MixLabelKind(rawValue: try decoder.singleValueContainer().decode(String.self)) ?? .unknown
	}
}

// MARK: - Discover

/// The Discover page, as returned by ``Recommendations/home(device:tzOffsetMinutes:)``.
public struct RecommendationHome: Codable, Sendable, Hashable {
	public let pageId: String
	/// The rows, in the order they were ranked.
	public let shelves: [RecommendationShelf]
	/// Mixes are being (re)built right now.
	public let refreshing: Bool
	/// When the mixes were last built, as a Unix timestamp in milliseconds.
	public let refreshedAt: Int64?
}

/// One row of the Discover page.
public struct RecommendationShelf: Codable, Sendable, Hashable, Identifiable {
	/// The ranking decision this row's cards were chosen under: send it back with ``Recommendations/feedback(decisionId:slot:event:msPlayed:)``.
	public let decisionId: String
	public let kind: RecommendationShelfKind
	public let row: Int
	public let cards: [RecommendationCard]

	public var id: String { decisionId }
}

/// One card of a Discover row.
public struct RecommendationCard: Codable, Sendable, Hashable, Identifiable {
	/// The card's position in its row, sent back with the feedback.
	public let slot: Int
	public let actionId: String
	public let item: RecommendationItem
	public let explanation: RecommendationExplanation

	public var id: String { actionId }
}

/// What a card shows.
public struct RecommendationItem: Codable, Sendable, Hashable {
	public let kind: RecommendationItemKind
	/// Mix ID, recording MBID (suggestion), release-group MBID (album), playlist ID or media ID (track).
	public let refId: String
	public let title: String
	public let subtitle: String?
	public let coverArt: String?
	/// A track carrying an uploaded cover, as in ``RecentlyPlayedEntry/coverMediaId``.
	public let coverMediaId: String?
	/// For playlists: the image's version stamp.
	public let playlistImage: String?
	/// Mixes: up to four covers for a mosaic.
	public let covers: [String]?
	/// Mixes: what the mix is about (title it in the app's language from this).
	public let label: MixLabel?
	/// The item's page in the web app.
	public let href: String
}

/// Why a card is shown.
public struct RecommendationExplanation: Codable, Sendable, Hashable {
	public let kind: RecommendationExplanationKind
	/// The artist or mix the explanation names, when it names one.
	public let subject: String?
}

/// Answer to ``Recommendations/feedback(decisionId:slot:event:msPlayed:)``.
public struct RecommendationFeedbackResponse: Codable, Sendable, Hashable {
	/// `recorded`, or `closed` when the 30-minute window was over (nothing recorded, not an error).
	public let status: String
}

// MARK: - Mixes

/// What a mix is about, structured so each client writes the title in its own language.
public struct MixLabel: Codable, Sendable, Hashable {
	public let kind: MixLabelKind
	public let value: String
	public let qualifier: MixLabelQualifier?
}

/// A second facet distinguishing two mixes that share the first.
public struct MixLabelQualifier: Codable, Sendable, Hashable {
	public let kind: MixLabelKind
	public let value: String
}

/// The caller's mixes, as returned by ``Recommendations/mixes``.
public struct MixList: Codable, Sendable, Hashable {
	public let mixes: [MixSummary]
	public let refreshing: Bool
	public let refreshedAt: Int64?
	/// The last refresh failed (the previous mixes, if any, are still listed).
	public let failed: Bool?
}

/// One mix, without its tracks.
public struct MixSummary: Codable, Sendable, Hashable, Identifiable {
	public let id: String
	public let position: Int
	public let label: MixLabel
	/// English title, for clients that do not localize ``label``.
	public let title: String
	public let topArtists: [String]
	public let trackCount: Int
	/// Tracks the caller can already play; the rest are suggestions.
	public let familiarCount: Int
	/// Up to four covers for a mosaic.
	public let covers: [String]
	/// Unix timestamp in milliseconds.
	public let refreshedAt: Int64
}

/// One mix with its tracks, as returned by ``Recommendations/mix(id:)``.
public struct MixDetail: Codable, Sendable, Hashable, Identifiable {
	public let id: String
	public let position: Int
	public let label: MixLabel
	public let title: String
	public let topArtists: [String]
	public let trackCount: Int
	public let familiarCount: Int
	public let covers: [String]
	public let refreshedAt: Int64
	/// In listening order.
	public let tracks: [MixTrack]
}

/// A track of a mix: either one the caller can play (``media``) or a catalogue suggestion (``suggestion``).
public struct MixTrack: Codable, Sendable, Hashable, Identifiable {
	public let position: Int
	public let familiar: Bool
	/// Familiar: how sure the server is the caller likes it. Suggestion: how well it fits the mix. 0-1.
	public let confidence: Double
	public let reason: MixTrackReason
	/// Familiar tracks: the media row, playable like a playlist track.
	public let media: MediaRow?
	/// Familiar tracks: whether it is in the caller's own library (else it is reachable through a playlist).
	public let inLibrary: Bool
	/// Suggestions: the catalogue recording.
	public let suggestion: MixSuggestion?

	public var id: Int { position }

	private enum CodingKeys: String, CodingKey {
		case position, familiar, confidence, reason, media, suggestion
	}

	private struct InLibraryProbe: Decodable {
		let inLibrary: Bool?
	}

	public init(position: Int, familiar: Bool, confidence: Double, reason: MixTrackReason, media: MediaRow?, inLibrary: Bool, suggestion: MixSuggestion?) {
		self.position = position
		self.familiar = familiar
		self.confidence = confidence
		self.reason = reason
		self.media = media
		self.inLibrary = inLibrary
		self.suggestion = suggestion
	}

	public init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		position = try c.decode(Int.self, forKey: .position)
		familiar = try c.decode(Bool.self, forKey: .familiar)
		confidence = try c.decode(Double.self, forKey: .confidence)
		reason = try c.decode(MixTrackReason.self, forKey: .reason)
		media = try c.decodeIfPresent(MediaRow.self, forKey: .media)
		// the server sends `inLibrary` inside the media object
		let probe = (try? c.decodeIfPresent(InLibraryProbe.self, forKey: .media)) ?? nil
		inLibrary = probe?.inLibrary ?? false
		suggestion = try c.decodeIfPresent(MixSuggestion.self, forKey: .suggestion)
	}

	public func encode(to encoder: Encoder) throws {
		var c = encoder.container(keyedBy: CodingKeys.self)
		try c.encode(position, forKey: .position)
		try c.encode(familiar, forKey: .familiar)
		try c.encode(confidence, forKey: .confidence)
		try c.encode(reason, forKey: .reason)
		try c.encodeIfPresent(media, forKey: .media)
		try c.encodeIfPresent(suggestion, forKey: .suggestion)
	}
}

/// Why a track is in a mix.
public struct MixTrackReason: Codable, Sendable, Hashable {
	/// `familiar` or `novel`.
	public let kind: String
	/// Familiar: qualifying plays.
	public let plays: Int?
	/// Familiar: last engagement, Unix milliseconds.
	public let lastPlayedAt: Int64?
	/// Novel: the evidence that weighed most — `collaborative`, `audio`, `text` or `graph`.
	public let via: String?
	/// Novel: the caller's artist it was found through.
	public let seedArtist: String?
	/// Novel: fit with the mix, 0-1.
	public let fit: Double?

	public var isFamiliar: Bool { kind == "familiar" }
}

/// A catalogue recording suggested in a mix: preview it with `Track.preview`, request it with `Request.create`.
public struct MixSuggestion: Codable, Sendable, Hashable {
	/// The MusicBrainz recording ID.
	public let recordingId: String
	public let title: String
	public let artist: String
	public let album: String?
	public let albumId: String?
	public let coverArt: String?
	public let durationMs: Double?
	/// Unix timestamp in milliseconds.
	public let releasedAt: Int64?
}

/// Answer to ``Recommendations/refreshMixes``.
public struct MixRefreshResponse: Codable, Sendable, Hashable {
	public let refreshing: Bool
}

// MARK: - Settings and models

/// The caller's personalization setting.
public struct RecommendationSettings: Codable, Sendable, Hashable {
	public let enabled: Bool
	/// `false` when the server has the recommender switched off.
	public let available: Bool
	/// Unix timestamp in milliseconds of the last change, `nil` if never changed.
	public let updatedAt: Int64?
}

/// A bandit model of the server, with its offline evaluation report (`ADMIN`).
public struct RecommendationModel: Codable, Sendable, Hashable, Identifiable {
	public let id: Int
	/// `shelf` or `card`.
	public let level: String
	/// `linucb`, `neural_ts` or `neural_ucb`.
	public let kind: String
	/// `active`, `candidate`, `retired` or `rejected`.
	public let status: String
	/// Pages served by this model.
	public let served: Int
	/// IPS / SNIPS / DM / DR estimates and the gate's verdict.
	public let metrics: JSONValue?
	public let createdAt: Int64
	public let updatedAt: Int64
}
