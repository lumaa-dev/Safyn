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

	/// How much of ``releaseDate`` MusicBrainz actually knows; a partial date is padded to its first day.
	public let releaseDatePrecision: ReleaseDatePrecision?

	/// `false` while the release date hasn't started anywhere yet. Unreleased albums can't be requested.
	public let released: Bool

	/// Whether the requesting user follows this upcoming album (see `Subscriptions.create`).
	public let subscribed: Bool

	/// Whether the requesting user has an active request for this album (waiting or being processed);
	/// `false` again once it completed, failed or was denied.
	public let requested: Bool

	/// Whether every track of the album is already in the requesting user's library. Such an album can't
	/// be requested again (`Request.create` fails with 409).
	public let inLibrary: Bool

	/// A description, if one is known.
	public let description: String?

	/// The record label, if known.
	public let label: String?

	/// One entry per disc, in order. Only show disc headers when there is more than one.
	public let discs: [DiscInfo]

	/// The album's tracklist, across all discs. Group by ``TrackInfo/discNumber`` for multi-disc albums.
	public let tracks: [TrackInfo]

	/// Dominant colors extracted from `coverArt`, most-dominant first.
	public let imageColors: [String]

	/// Black or white, whichever contrasts best (WCAG) against `imageColors[0]`.
	public let textColor: String

	public init(id: String, releaseId: String, title: String, artist: ArtistRef, type: AlbumKind?, coverArt: String?, releaseDate: Date?, releaseDatePrecision: ReleaseDatePrecision?, released: Bool, subscribed: Bool, requested: Bool, inLibrary: Bool, description: String?, label: String?, discs: [DiscInfo], tracks: [TrackInfo], imageColors: [String], textColor: String) {
		self.id = id
		self.releaseId = releaseId
		self.title = title
		self.artist = artist
		self.type = type
		self.coverArt = coverArt
		self.releaseDate = releaseDate
		self.releaseDatePrecision = releaseDatePrecision
		self.released = released
		self.subscribed = subscribed
		self.requested = requested
		self.inLibrary = inLibrary
		self.description = description
		self.label = label
		self.discs = discs
		self.tracks = tracks
		self.imageColors = imageColors
		self.textColor = textColor
	}
}
