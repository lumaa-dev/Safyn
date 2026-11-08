// Made by Lumaa

import Foundation

/// What kind of releases an artist's ``ReleaseCategory`` holds.
public enum ReleaseCategoryID: String, Codable, Sendable, Hashable, CaseIterable {
	case album
	case ep
	case single
	case compilation
	case live
	case remix
	case soundtrack
	case other

	public init(from decoder: Decoder) throws {
		let raw = try decoder.singleValueContainer().decode(String.self)
		self = ReleaseCategoryID(rawValue: raw) ?? .other
	}
}

/// One card of an artist's discography: a release-group, or one *edition* of it.
///
/// An edition is the Deluxe or Remaster release of an album that has a standard one, listed next to it even when
/// MusicBrainz holds it inside the standard edition's release-group (like "Pinkerton" by Weezer). ``media`` is
/// then still the album's release-group (``MediaInfo/id``), with the edition's own title, cover and date; open it
/// with `Album.get(aid: media.id, release: releaseId)`.
public struct ArtistRelease: Codable, Sendable, Hashable, Identifiable {
	/// Which edition of the album ``releaseId`` is.
	public enum Edition: String, Codable, Sendable, Hashable {
		case deluxe
		case remaster
	}

	/// The release-group (or the edition shown as one), shaped like any other album.
	public let media: MediaInfo

	/// The release to open the album on; `nil` for the release-group itself.
	public let releaseId: String?

	/// Set on the Deluxe / Remaster edition of an album that has a standard one.
	public let edition: Edition?

	public var id: String {
		"\(media.id)-\(releaseId ?? "")"
	}

	public init(media: MediaInfo, releaseId: String? = nil, edition: Edition? = nil) {
		self.media = media
		self.releaseId = releaseId
		self.edition = edition
	}

	private enum ExtraKeys: String, CodingKey {
		case releaseId, edition
	}

	public init(from decoder: Decoder) throws {
		media = try MediaInfo(from: decoder)
		let container = try decoder.container(keyedBy: ExtraKeys.self)
		releaseId = try container.decodeIfPresent(String.self, forKey: .releaseId)
		edition = try? container.decodeIfPresent(Edition.self, forKey: .edition)
	}

	public func encode(to encoder: Encoder) throws {
		try media.encode(to: encoder)
		var container = encoder.container(keyedBy: ExtraKeys.self)
		try container.encode(releaseId, forKey: .releaseId)
		try container.encode(edition, forKey: .edition)
	}
}

/// The artist's releases of one kind (Albums, EPs, Singles...), newest first.
public struct ReleaseCategory: Codable, Sendable, Hashable, Identifiable {
	public let id: ReleaseCategoryID

	/// Newest first, the ones without a date last.
	public let releases: [ArtistRelease]

	public init(id: ReleaseCategoryID, releases: [ArtistRelease]) {
		self.id = id
		self.releases = releases
	}
}

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
	/// Every release-group, newest first, all kinds mixed (see ``categories``).
	public let albums: [MediaInfo]

	/// The discography by kind, in display order (Albums, EPs, Singles, Compilations, Live, Remixes, Soundtracks,
	/// Other); kinds with nothing in them are left out. Includes the Deluxe / Remaster editions of standard albums.
	/// Empty from a server older than the categories.
	public let categories: [ReleaseCategory]

	private enum CodingKeys: String, CodingKey {
		case id, name, image, bio, listeners, albums, categories
	}

	public init(id: String, name: String, image: String?, bio: String?, listeners: Double?, albums: [MediaInfo], categories: [ReleaseCategory] = []) {
		self.id = id
		self.name = name
		self.image = image
		self.bio = bio
		self.listeners = listeners
		self.albums = albums
		self.categories = categories
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		id = try container.decode(String.self, forKey: .id)
		name = try container.decode(String.self, forKey: .name)
		image = try container.decodeIfPresent(String.self, forKey: .image)
		bio = try container.decodeIfPresent(String.self, forKey: .bio)
		listeners = try container.decodeIfPresent(Double.self, forKey: .listeners)
		albums = try container.decode([MediaInfo].self, forKey: .albums)
		categories = try container.decodeIfPresent([ReleaseCategory].self, forKey: .categories) ?? []
	}
}
