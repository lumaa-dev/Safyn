// Made by Lumaa

import Foundation

/// A single disc of an ``AlbumDetail``. Multi-disc albums list one entry per disc in ``AlbumDetail/discs``.
public struct DiscInfo: Codable, Sendable, Hashable {
	/// The disc's number, matching ``TrackInfo/discNumber``.
	public let number: Double

	/// The disc's title, if it has one.
	public let title: String?

	public init(number: Double, title: String?) {
		self.number = number
		self.title = title
	}
}
