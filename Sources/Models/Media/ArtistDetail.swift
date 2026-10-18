// Made by Lumaa

import Foundation

/// Full artist details: name, Last.fm bio/image (if configured server-side), and discography, with
/// per-album library status for the requesting user.
///
/// Returned by `Artist.get(aid:)`.
public struct ArtistDetail: Codable, Sendable, Hashable {
	/// The artist's MusicBrainz ID.
	public let id: String

	/// The artist's name.
	public let name: String

	/// An image URL from Last.fm, if known. Often `nil` — Last.fm stopped serving real per-artist photos years ago.
	public let image: String?

	/// A biography from Last.fm, if known.
	public let bio: String?

	/// The Last.fm listener count, if known.
	public let listeners: Double?

	/// The artist's discography from MusicBrainz, with per-album library status for the requesting user.
	public let albums: [MediaInfo]

	public init(id: String, name: String, image: String?, bio: String?, listeners: Double?, albums: [MediaInfo]) {
		self.id = id
		self.name = name
		self.image = image
		self.bio = bio
		self.listeners = listeners
		self.albums = albums
	}
}
