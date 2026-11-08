// Made by Lumaa

import Foundation

/// One release of an album's release-group (the standard edition, a Deluxe, another country, a reissue...): what
/// "change release" offers. Open one with `Album.get(aid:release:)`.
public struct AlbumRelease: Codable, Sendable, Hashable, Identifiable {
	/// The MusicBrainz release ID.
	public let id: String

	public let title: String

	/// MusicBrainz' own words for what sets it apart ("deluxe edition", "2011 remaster"); `nil` when it has none.
	/// The description to show under the release.
	public let disambiguation: String?

	/// `"2010-11-02"`, `"2010-11"` or `"2010"`; `nil` when undated.
	public let date: String?

	public let country: String?

	/// `"Digital Media"`, `"CD"`... (`"CD + DVD"` for several).
	public let format: String?

	public let trackCount: Double

	/// The release's own front cover; `nil` when it has none.
	public let coverArt: String?

	/// Whether this is the release the response shows.
	public let selected: Bool

	public init(id: String, title: String, disambiguation: String? = nil, date: String? = nil, country: String? = nil, format: String? = nil, trackCount: Double = 0, coverArt: String? = nil, selected: Bool = false) {
		self.id = id
		self.title = title
		self.disambiguation = disambiguation
		self.date = date
		self.country = country
		self.format = format
		self.trackCount = trackCount
		self.coverArt = coverArt
		self.selected = selected
	}

	/// What to show under the release: its disambiguation when it has one, else its year and country.
	public var summary: String {
		if let disambiguation, !disambiguation.isEmpty { return disambiguation }
		return [date.map { String($0.prefix(4)) }, country].compactMap { $0 }.filter { !$0.isEmpty }.joined(separator: " · ")
	}
}

/// Full album/EP details: tracklist, artist, and cover art, with per-track library/request status for the requesting user.
///
/// Returned by `Album.get(aid:)`.
public struct AlbumDetail: Codable, Sendable, Hashable {
	/// The MusicBrainz release-group ID.
	public let id: String

	/// The MusicBrainz release ID for the selected release.
	public let releaseId: String

	/// `false` when `Album.get(aid:release:)` picked a release other than the standard one. The album can then only be
	/// requested track by track (an album request downloads the standard edition).
	public let isDefaultRelease: Bool

	/// Every official release of the release-group, oldest first, to choose another one from; exactly one has
	/// ``AlbumRelease/selected``. Empty from a server older than release picking.
	public let releases: [AlbumRelease]

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

	private enum CodingKeys: String, CodingKey {
		case id, releaseId, isDefaultRelease, releases, title, artist, type, coverArt, releaseDate, releaseDatePrecision, released, subscribed, requested, inLibrary, description, label, discs, tracks, imageColors, textColor
	}

	public init(id: String, releaseId: String, title: String, artist: ArtistRef, type: AlbumKind?, coverArt: String?, releaseDate: Date?, releaseDatePrecision: ReleaseDatePrecision?, released: Bool, subscribed: Bool, requested: Bool, inLibrary: Bool, description: String?, label: String?, discs: [DiscInfo], tracks: [TrackInfo], imageColors: [String], textColor: String, isDefaultRelease: Bool = true, releases: [AlbumRelease] = []) {
		self.id = id
		self.releaseId = releaseId
		self.isDefaultRelease = isDefaultRelease
		self.releases = releases
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

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		releaseId = try container.decode(String.self, forKey: .releaseId)
		isDefaultRelease = try container.decodeIfPresent(Bool.self, forKey: .isDefaultRelease) ?? true
		releases = try container.decodeIfPresent([AlbumRelease].self, forKey: .releases) ?? []
		title = try container.decode(String.self, forKey: .title)
		artist = try container.decode(ArtistRef.self, forKey: .artist)
		type = try container.decodeIfPresent(AlbumKind.self, forKey: .type)
		coverArt = try container.decodeIfPresent(String.self, forKey: .coverArt)
		releaseDate = try container.decodeIfPresent(Date.self, forKey: .releaseDate)
		releaseDatePrecision = try container.decodeIfPresent(ReleaseDatePrecision.self, forKey: .releaseDatePrecision)
		released = try container.decode(Bool.self, forKey: .released)
		subscribed = try container.decode(Bool.self, forKey: .subscribed)
		requested = try container.decode(Bool.self, forKey: .requested)
		inLibrary = try container.decode(Bool.self, forKey: .inLibrary)
		description = try container.decodeIfPresent(String.self, forKey: .description)
		label = try container.decodeIfPresent(String.self, forKey: .label)
		discs = try container.decode([DiscInfo].self, forKey: .discs)
		tracks = try container.decode([TrackInfo].self, forKey: .tracks)
		imageColors = try container.decode([String].self, forKey: .imageColors)
		textColor = try container.decode(String.self, forKey: .textColor)
	}
}
