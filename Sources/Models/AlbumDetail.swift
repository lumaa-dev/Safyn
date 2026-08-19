// Made by Lumaa

import Foundation

/// Full album/EP details: tracklist, artist, and cover art, with per-track library/request status for the requesting user.
///
/// Returned by `Album.get(aid:)`.
public struct AlbumDetail: Codable, Sendable, Hashable {
	/// The MusicBrainz release-group ID.
	public let id: String

	/// The MusicBrainz release ID for the selected release.
	public let releaseId: String

	/// The album's title.
	public let title: String

	/// The album's artist.
	public let artist: ArtistRef

	/// Whether this is a full album or an EP, if known.
	public let type: AlbumKind?

	/// A cover art URL, if one is known.
	public let coverArt: String?

	/// The release date, if known.
	public let releaseDate: Date?

	/// A description, if one is known.
	public let description: String?

	/// The record label, if known.
	public let label: String?

	/// The album's tracklist.
	public let tracks: [TrackInfo]

	public init(id: String, releaseId: String, title: String, artist: ArtistRef, type: AlbumKind?, coverArt: String?, releaseDate: Date?, description: String?, label: String?, tracks: [TrackInfo]) {
		self.id = id
		self.releaseId = releaseId
		self.title = title
		self.artist = artist
		self.type = type
		self.coverArt = coverArt
		self.releaseDate = releaseDate
		self.description = description
		self.label = label
		self.tracks = tracks
	}
}
