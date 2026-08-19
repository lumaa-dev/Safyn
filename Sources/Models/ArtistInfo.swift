// Made by Lumaa

import Foundation

/// A resolved artist's MusicBrainz metadata.
public struct ArtistInfo: Codable, Sendable, Hashable {
	/// The artist's name.
	public let name: String

	/// The artist's MusicBrainz ID.
	public let musicbrainzId: String

	/// A biography/description, if MusicBrainz has one.
	public let description: String?

	/// An image URL, if MusicBrainz has one.
	public let image: String?

	public init(name: String, musicbrainzId: String, description: String?, image: String?) {
		self.name = name
		self.musicbrainzId = musicbrainzId
		self.description = description
		self.image = image
	}
}
