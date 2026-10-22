// Made by Lumaa

import Foundation

/// Score breakdown of an album/track search result.
public struct SearchMatch: Codable, Sendable, Hashable {
	/// Extra signals about why a result scored the way it did.
	public enum Flag: String, Codable, Sendable, Hashable {
		case upcMatch = "upc_match"
		case isrcMatch = "isrc_match"
		case codeContradiction = "code_contradiction"
		case artistOnly = "artist_only"
		case swappedOrder = "swapped_order"
		case noFrontCover = "no_front_cover"
		/// A flag this client doesn't know yet.
		case unknown

		public init(from decoder: Decoder) throws {
			let raw = try decoder.singleValueContainer().decode(String.self)
			self = Flag(rawValue: raw) ?? .unknown
		}
	}

	/// Containment score of the title, `0...1` (`1` when no title was given).
	public let title: Double

	/// Best artist similarity over name, aliases and sort names, `0...1` (`1` when no artist was given).
	public let artist: Double

	/// Weighted title/artist score plus corroboration and UPC/ISRC bonuses; may exceed `1`.
	public let relevance: Double

	/// Levenshtein ratio of the normalized titles, `0...1`.
	public let exactness: Double

	/// How many independent searches found this result.
	public let sources: Double

	/// Whether the best qualifying release has a front cover. Results with one rank first.
	public let hasFrontCover: Bool

	/// Extra signals about the match.
	public let flags: [Flag]

	public init(title: Double, artist: Double, relevance: Double, exactness: Double, sources: Double, hasFrontCover: Bool, flags: [Flag]) {
		self.title = title
		self.artist = artist
		self.relevance = relevance
		self.exactness = exactness
		self.sources = sources
		self.hasFrontCover = hasFrontCover
		self.flags = flags
	}
}
