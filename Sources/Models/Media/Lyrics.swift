// Made by Lumaa

import Foundation

/// Synced lyrics for a library track, returned by `Library.lyrics(id:)`.
public struct Lyrics: Codable, Sendable, Hashable {
	/// A single timed word/segment within a ``Line``.
	public struct Segment: Codable, Sendable, Hashable {
		public let id: String
		public let text: String
		public let startTime: Double
		public let endTime: Double
		public let endsWord: Bool

		public init(id: String, text: String, startTime: Double, endTime: Double, endsWord: Bool) {
			self.id = id
			self.text = text
			self.startTime = startTime
			self.endTime = endTime
			self.endsWord = endsWord
		}
	}

	/// A single lyric line, made up of timed segments.
	public struct Line: Codable, Sendable, Hashable {
		/// Whether a line is the main vocal or background vocals, and whether it's an alternate reading.
		public struct Kind: Codable, Sendable, Hashable {
			public enum Category: String, Codable, Sendable, Hashable {
				case main
				case background
			}

			public let kind: Category
			public let alt: Bool

			public init(kind: Category, alt: Bool) {
				self.kind = kind
				self.alt = alt
			}
		}

		public let id: String
		public let text: String
		public let startTime: Double
		public let endTime: Double
		public let type: Kind
		public let segments: [Segment]

		public init(id: String, text: String, startTime: Double, endTime: Double, type: Kind, segments: [Segment]) {
			self.id = id
			self.text = text
			self.startTime = startTime
			self.endTime = endTime
			self.type = type
			self.segments = segments
		}
	}

	/// A paragraph grouping consecutive lines.
	public struct Paragraph: Codable, Sendable, Hashable {
		public let id: String
		public let lines: [Line]

		public init(id: String, lines: [Line]) {
			self.id = id
			self.lines = lines
		}
	}

	/// What a provider's licence asks to be shown with its lyrics. Today only Unison's, which requires crediting
	/// Unison and the person who submitted the lyrics, each linked to their page, by 7 February 2027.
	public struct Credit: Codable, Sendable, Hashable {
		/// Who submitted the lyrics, with the link to their page.
		public struct Submitter: Codable, Sendable, Hashable {
			public let name: String
			public let url: URL

			public init(name: String, url: URL) {
				self.name = name
				self.url = url
			}
		}

		/// `Lyrics from Unison`; show it linked to ``url``.
		public let text: String
		/// The provider's page for this song, where a wrong line can be voted on, reported or fixed.
		public let url: URL
		/// The submitter, when the provider names one.
		public let submitter: Submitter?

		public init(text: String, url: URL, submitter: Submitter? = nil) {
			self.text = text
			self.url = url
			self.submitter = submitter
		}
	}

	/// The service that provided these lyrics.
	public let provider: LyricsProvider

	/// The lyrics, grouped into paragraphs.
	public let paragraphs: [Paragraph]

	/// The credit to show with the lyrics, when the provider's licence requires one (`nil` otherwise).
	public let credit: Credit?

	public init(provider: LyricsProvider, paragraphs: [Paragraph], credit: Credit? = nil) {
		self.provider = provider
		self.paragraphs = paragraphs
		self.credit = credit
	}
}
