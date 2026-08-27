// Made by Lumaa

import Foundation

/// One slide of a ``HighlightReel``'s in-app story player.
public struct ReelSlide: Codable, Sendable, Hashable {
	/// The kind of slide, driving which fields are populated and how it's rendered.
	public enum Kind: String, Codable, Sendable, Hashable {
		case intro
		case stat
		case track
		case artist
		case outro
	}

	/// The slide's kind.
	public let kind: Kind

	/// An i18n key for the slide's caption, if it has one.
	public let label: String?

	/// A pre-formatted headline number, if the slide has one.
	public let value: String?

	/// The slide's title, if any.
	public let title: String?

	/// The slide's subtitle, if any.
	public let subtitle: String?

	/// A cover art URL, if any.
	public let cover: String?

	/// The media ID to stream via `Library.stream(id:)` for the slide's audio excerpt, if any.
	public let trackId: String?

	/// The excerpt's start offset, in seconds, if the slide has an audio excerpt.
	public let excerptStartSeconds: Int?

	/// The excerpt's duration, in seconds, if the slide has an audio excerpt.
	public let excerptSeconds: Int?

	public init(kind: Kind, label: String?, value: String?, title: String?, subtitle: String?, cover: String?, trackId: String?, excerptStartSeconds: Int?, excerptSeconds: Int?) {
		self.kind = kind
		self.label = label
		self.value = value
		self.title = title
		self.subtitle = subtitle
		self.cover = cover
		self.trackId = trackId
		self.excerptStartSeconds = excerptStartSeconds
		self.excerptSeconds = excerptSeconds
	}
}
