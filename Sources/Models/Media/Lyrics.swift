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

	/// The service that provided these lyrics.
	public let provider: LyricsProvider

	/// The lyrics, grouped into paragraphs.
	public let paragraphs: [Paragraph]

	public init(provider: LyricsProvider, paragraphs: [Paragraph]) {
		self.provider = provider
		self.paragraphs = paragraphs
	}
}
