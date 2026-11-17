// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/library/` path.
public enum Library: NafynEndpoint {

	/// Remove a track from the requesting user's own library. If no other user still references the
	/// underlying file, it's deleted too.
	///
	/// Returns ``RemovedWithFileResponse``.
	/// - Parameter id: Media ID.
	case remove(id: String)

	/// Remove a track from a specific user's library. Only that user themselves, or a user with `manageMusic`, may do this.
	///
	/// Returns ``RemovedWithFileResponse``.
	/// - Parameters:
	///   - id: Media ID.
	///   - userId: ID of the user whose library entry is being removed.
	case removeForUser(id: String, userId: String)

	/// Get the lyrics of a library track: the user-supplied ones, else the providers (Unison, Better Lyrics, Better Lyrics Portato, Cider, LRCLIB) in order until one has a match. Parsed by Braccato and sent in its `Lyric[]` shape: syllable/word timing is in each line's `parts`. Answers are cached by the server for 20 minutes, with the track's lyric offset.
	///
	/// Returns ``Lyrics``.
	/// - Parameter id: Media ID.
	case lyrics(id: String)

	/// Stream an owned track's audio file, with HTTP Range support for progressive playback.
	///
	/// Returns raw audio `Data` — send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// - Parameters:
	///   - id: Media ID.
	///   - token: Auth token, as a fallback for clients that can't set the Authorization header (e.g. `<audio>` elements).
	///   - range: A standard HTTP byte-range value, e.g. `"bytes=0-1023"`.
	case stream(id: String, token: String? = nil, range: String? = nil)

	/// Get one album's metadata plus only the tracks the requesting user owns from it - used by the library album
	/// view (Play/Shuffle, no Request buttons, hides tracks the user doesn't have).
	///
	/// Returns ``LibraryAlbumResponse``.
	/// - Parameter id: MusicBrainz release-group ID.
	case album(id: String)

	/// List every album the requesting user owns at least one track from, aggregated from their library. Paginated.
	///
	/// Returns `[`` AlbumRow``]`. The spec doesn't detail a pagination envelope for this endpoint (unlike
	/// ``all(page:limit:)``), so this decodes as a bare array; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - limit: Maximum number of results to return.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	///   - query: Search text: every word has to be found in the album's title or in the artist of one of its tracks. Empty is the same as `nil`.
	///   - sort: The order of the list. Defaults to ``LibrarySort/added`` server-side when omitted.
	case albums(limit: Int? = nil, offset: Int? = nil, query: String? = nil, sort: LibrarySort? = nil)

	/// List every media row across every user's library, with owner usernames. Paginated. Requires `manageMusic`.
	///
	/// Returns ``PaginatedResponse``<``LibraryMediaEntry``>.
	/// - Parameters:
	///   - page: Page number, 1-indexed. Defaults to `1` server-side when omitted.
	///   - limit: Maximum number of results per page.
	case all(page: Int? = nil, limit: Int? = nil)

	/// List the requesting user's recently played tracks/albums/playlists, most recent first.
	///
	/// Returns `[`` RecentlyPlayedEntry``]`.
	case recentlyPlayed

	/// Record a track/album/playlist as recently played for the requesting user.
	///
	/// Returns ``RecordedResponse``.
	/// - Parameters:
	///   - type: The kind of media being recorded.
	///   - refId: Media ID (track), release-group ID (album), or playlist ID.
	case recordRecentlyPlayed(type: RecentEntryKind, refId: String)

	/// Get one track the requesting user owns, by Nafyn media ID - used by the library track view (Play, no Request
	/// button).
	///
	/// Returns ``LibraryTrackResponse``.
	/// - Parameter id: Nafyn's internal media ID.
	case track(id: String)

	/// List every track in the requesting user's library. Paginated.
	///
	/// Returns `[`` MediaRow``]`. The spec doesn't detail a pagination envelope for this endpoint (unlike
	/// ``all(page:limit:)``), so this decodes as a bare array; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - limit: Maximum number of results to return.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	///   - query: Search text: every word has to be found in the track's title, artist or album. Empty is the same as `nil`.
	///   - sort: The order of the list. Defaults to ``LibrarySort/added`` server-side when omitted.
	case tracks(limit: Int? = nil, offset: Int? = nil, query: String? = nil, sort: LibrarySort? = nil)

	/// Edit the metadata of a track in the requesting user's library. Only the provided fields are changed.
	///
	/// Returns ``MediaRow``.
	/// - Parameters:
	///   - id: Nafyn media ID.
	///   - title: The track's title.
	///   - artistName: The track's artist name.
	///   - album: The album title. Use `.clear` to unset it, `.value(_:)` to set it, or leave `.unset` to not change it.
	///   - albumType: Whether the album is a full album or an EP. Use `.clear` to unset it, `.value(_:)` to set it, or leave `.unset` to not change it.
	///   - releaseDate: The release date, as Unix seconds. Use `.clear` to unset it, `.value(_:)` to set it, or leave `.unset` to not change it.
	///   - duration: The track's duration, in seconds.
	///   - label: The record label. Use `.clear` to unset it, `.value(_:)` to set it, or leave `.unset` to not change it.
	///   - trackNumber: The track's number within its album. Use `.clear` to unset it, `.value(_:)` to set it, or leave `.unset` to not change it.
	///   - coverArt: A Cover Art Archive URL. Use `.clear` to unset it, `.value(_:)` to set it, or leave `.unset` to not change it.
	///     Uploaded covers go through ``setCover(id:data:filename:mimeType:)`` instead.
	case editMetadata(id: String, title: String? = nil, artistName: String? = nil, album: Patchable<String> = .unset, albumType: Patchable<AlbumKind> = .unset, releaseDate: Patchable<Double> = .unset, duration: Double? = nil, label: Patchable<String> = .unset, trackNumber: Patchable<Double> = .unset, coverArt: Patchable<String> = .unset)

	/// Move a track of the requesting user's library to another album. The album's title, type, cover, date and
	/// the track's disc and position on it come from MusicBrainz; the file moves into the album's folder, and the
	/// folder it leaves is removed when empty. An album left with no track disappears from the library.
	///
	/// Like ``editMetadata(id:title:artistName:album:albumType:releaseDate:duration:label:trackNumber:coverArt:)``,
	/// an ordinary user may only move a track no other user has (`403` otherwise); `manageMusic` may move any.
	/// Answers `404` when the track isn't in the library or MusicBrainz knows no such album, `503` when MusicBrainz is unavailable.
	///
	/// Returns ``MediaRow``.
	/// - Parameters:
	///   - id: Nafyn media ID.
	///   - albumId: MusicBrainz release-group ID of the album to move the track to (a search result's ``MediaInfo/id``).
	case changeAlbum(id: String, albumId: String)

	/// Get the user-uploaded cover image of a library track (`image/webp`).
	///
	/// Returns raw `Data` — send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// - Parameters:
	///   - id: Nafyn media ID.
	///   - token: Auth token, as a fallback for clients that can't set the Authorization header (e.g. `<img>` elements).
	case cover(id: String, token: String? = nil)

	/// Get a Cover Art Archive front cover through Nafyn's cache (`image/jpeg`).
	///
	/// Returns raw `Data` — send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``. The server
	/// answers `404` when the archive has no cover and `504` when it isn't cached yet and the archive was too
	/// slow; retry the latter shortly.
	/// - Parameters:
	///   - type: Whether `id` is a MusicBrainz release or release-group ID.
	///   - id: MusicBrainz release / release-group ID.
	///   - size: Thumbnail edge in pixels.
	///   - token: Auth token, as a fallback for clients that can't set the Authorization header (e.g. `<img>` elements).
	case coverArt(type: CoverArtKind, id: String, size: CoverArtSize, token: String? = nil)

	/// Upload a cover image (PNG/JPEG/WebP) for a library track.
	///
	/// Returns ``MediaRow``.
	/// - Parameters:
	///   - id: Nafyn media ID.
	///   - data: The image's raw bytes.
	///   - filename: Reported in the upload's `Content-Disposition` header. Defaults to `"cover.jpg"`.
	///   - mimeType: The image's MIME type. Defaults to `"image/jpeg"`.
	case setCover(id: String, data: Data, filename: String = "cover.jpg", mimeType: String = "image/jpeg")

	/// Remove the user-uploaded cover image of a library track.
	///
	/// Returns ``MediaRow``.
	/// - Parameter id: Nafyn media ID.
	case deleteCover(id: String)

	/// Set the user-supplied lyrics of a library track.
	///
	/// - Parameters:
	///   - id: Nafyn media ID.
	///   - content: The lyrics text.
	///   - format: The lyrics format. Defaults to `.plain`.
	case setLyrics(id: String, content: String, format: LyricsFormat = .plain)

	/// Remove the user-supplied lyrics of a library track.
	///
	/// - Parameter id: Nafyn media ID.
	case deleteLyrics(id: String)

	/// Move a track's synced lyrics earlier or later against its audio. The offset belongs to the track (every listener
	/// gets it) and is kept with its cached lyrics, so it lasts as long as they do (20 minutes). Unsynced lyrics take none (404).
	///
	/// Returns ``LyricsOffset``.
	/// - Parameters:
	///   - id: Nafyn media ID.
	///   - offsetMs: Milliseconds the lyrics are shown later (negative: earlier), within ±30000.
	case setLyricsOffset(id: String, offsetMs: Int)

	/// Import an audio file into the requesting user's library with user-supplied metadata.
	///
	/// Returns ``MediaRow``.
	/// - Parameters:
	///   - audio: The audio file's raw bytes.
	///   - audioFilename: Reported in the upload's `Content-Disposition` header for the audio part.
	///   - audioMimeType: The audio file's MIME type.
	///   - cover: A cover image's raw bytes (PNG/JPEG/WebP), if any.
	///   - coverFilename: Reported in the upload's `Content-Disposition` header for the cover part. Defaults to `"cover.jpg"`.
	///   - coverMimeType: The cover image's MIME type. Defaults to `"image/jpeg"`.
	///   - metadata: A JSON object string with any of: `title`, `artist`, `album`, `albumType`, `duration`, `trackNumber`, `releaseDate`, `label`, `lyrics`.
	case importTrack(audio: Data, audioFilename: String, audioMimeType: String, cover: Data? = nil, coverFilename: String = "cover.jpg", coverMimeType: String = "image/jpeg", metadata: String? = nil)

	/// List the cover art available for an album, from its MusicBrainz release-group: the group's own
	/// front cover plus the front cover of each release that has one.
	///
	/// Returns ``CoverOptionsResponse``. Store a chosen ``CoverOption/url`` as `coverArt` with ``editMetadata(id:title:artistName:album:albumType:releaseDate:duration:label:trackNumber:coverArt:)``.
	/// - Parameter albumId: MusicBrainz release-group ID (the `albumId` of a track).
	case coverOptions(albumId: String)

	/// List the cover art available for ONE track: the front cover of every release its MusicBrainz recording is
	/// on, whatever release-group they belong to. Entries without a front cover are never listed.
	///
	/// Returns ``CoverOptionsResponse``. Store a chosen ``CoverOption/url`` as `coverArt` with ``editMetadata(id:title:artistName:album:albumType:releaseDate:duration:label:trackNumber:coverArt:)``.
	/// - Parameter recordingId: MusicBrainz recording ID (the `musicbrainzId` of a track).
	case coverOptionsForRecording(recordingId: String)

	public var path: String {
		switch self {
			case .remove(let id):
				return "/api/v1/library/\(id)"
			case .removeForUser(let id, let userId):
				return "/api/v1/library/\(id)/\(userId)"
			case .lyrics(let id), .setLyrics(let id, _, _), .deleteLyrics(let id):
				return "/api/v1/library/\(id)/lyrics"
			case .setLyricsOffset(let id, _):
				return "/api/v1/library/\(id)/lyrics/offset"
			case .stream(let id, _, _):
				return "/api/v1/library/\(id)/stream"
			case .album(let id):
				return "/api/v1/library/album/\(id)"
			case .albums:
				return "/api/v1/library/albums"
			case .all:
				return "/api/v1/library/all"
			case .recentlyPlayed, .recordRecentlyPlayed:
				return "/api/v1/library/recently-played"
			case .track(let id):
				return "/api/v1/library/track/\(id)"
			case .tracks:
				return "/api/v1/library/tracks"
			case .editMetadata(let id, _, _, _, _, _, _, _, _, _):
				return "/api/v1/library/\(id)"
			case .changeAlbum(let id, _):
				return "/api/v1/library/\(id)/album"
			case .cover(let id, _), .setCover(let id, _, _, _), .deleteCover(let id):
				return "/api/v1/library/\(id)/cover"
			case .coverArt(let type, let id, let size, _):
				return "/api/v1/art/\(type.rawValue)/\(id)/\(size.rawValue)"
			case .importTrack:
				return "/api/v1/library/import"
			case .coverOptions, .coverOptionsForRecording:
				return "/api/v1/library/cover-options"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .remove, .removeForUser, .deleteCover, .deleteLyrics:
				return [.delete]
			case .lyrics, .stream, .album, .albums, .all, .recentlyPlayed, .track, .tracks, .cover, .coverArt, .coverOptions, .coverOptionsForRecording:
				return [.get]
			case .recordRecentlyPlayed, .importTrack:
				return [.post]
			case .editMetadata:
				return [.patch]
			case .setLyrics, .setLyricsOffset, .setCover, .changeAlbum:
				return [.put]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .stream(_, let token, _):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
			case .cover(_, let token), .coverArt(_, _, _, let token):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
			case .albums(let limit, let offset, let query, let sort), .tracks(let limit, let offset, let query, let sort):
				var items: [URLQueryItem] = []
				if let limit {
					items.append(URLQueryItem(name: "limit", value: String(limit)))
				}
				if let offset {
					items.append(URLQueryItem(name: "offset", value: String(offset)))
				}
				if let query = query?.trimmingCharacters(in: .whitespacesAndNewlines), !query.isEmpty {
					items.append(URLQueryItem(name: "q", value: query))
				}
				if let sort {
					items.append(URLQueryItem(name: "sort", value: sort.rawValue))
				}
				return items
			case .all(let page, let limit):
				var items: [URLQueryItem] = []
				if let page {
					items.append(URLQueryItem(name: "page", value: String(page)))
				}
				if let limit {
					items.append(URLQueryItem(name: "limit", value: String(limit)))
				}
				return items
			case .coverOptions(let albumId):
				return [URLQueryItem(name: "albumId", value: albumId)]
			case .coverOptionsForRecording(let recordingId):
				return [URLQueryItem(name: "recordingId", value: recordingId)]
			default:
				return []
		}
	}

	public var headers: [String: String] {
		switch self {
			case .stream(_, _, let range):
				guard let range else { return [:] }
				return ["Range": range]
			default:
				return [:]
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .recordRecentlyPlayed(let type, let refId):
				return AnyEncodable(RecordRecentlyPlayedRequest(type: type, refId: refId))
			case .editMetadata(_, let title, let artistName, let album, let albumType, let releaseDate, let duration, let label, let trackNumber, let coverArt):
				return AnyEncodable(EditTrackMetadataRequest(title: title, artistName: artistName, album: album, albumType: albumType, releaseDate: releaseDate, duration: duration, label: label, trackNumber: trackNumber, coverArt: coverArt))
			case .setLyrics(_, let content, let format):
				return AnyEncodable(SetTrackLyricsRequest(content: content, format: format))
			case .setLyricsOffset(_, let offsetMs):
				return AnyEncodable(SetLyricsOffsetRequest(offsetMs: offsetMs))
			case .changeAlbum(_, let albumId):
				return AnyEncodable(ChangeTrackAlbumRequest(albumId: albumId))
			default:
				return nil
		}
	}

	public var multipart: [MultipartPart]? {
		switch self {
			case .setCover(_, let data, let filename, let mimeType):
				return [.file(fieldName: "cover", filename: filename, mimeType: mimeType, data: data)]
			case .importTrack(let audio, let audioFilename, let audioMimeType, let cover, let coverFilename, let coverMimeType, let metadata):
				var parts: [MultipartPart] = [.file(fieldName: "audio", filename: audioFilename, mimeType: audioMimeType, data: audio)]
				if let cover {
					parts.append(.file(fieldName: "cover", filename: coverFilename, mimeType: coverMimeType, data: cover))
				}
				if let metadata {
					parts.append(.text(fieldName: "metadata", value: metadata))
				}
				return parts
			default:
				return nil
		}
	}
}

/// Which kind of MusicBrainz ID `Library.coverArt(type:id:size:token:)` is given.
public enum CoverArtKind: String, Codable, Sendable, Hashable {
	/// A MusicBrainz release ID.
	case release

	/// A MusicBrainz release-group ID.
	case releaseGroup = "release-group"
}

/// The thumbnail edge, in pixels, that `Library.coverArt(type:id:size:token:)` accepts.
public enum CoverArtSize: Int, Codable, Sendable, Hashable {
	case small = 250
	case medium = 500
	case large = 1000
}

/// The order of ``Library/tracks(limit:offset:query:sort:)`` and ``Library/albums(limit:offset:query:sort:)``.
public enum LibrarySort: String, Codable, Sendable, Hashable, CaseIterable, Identifiable {
	/// Recently added first. The server's default.
	case added

	/// Alphabetical by title, A-Z.
	case title

	/// Alphabetical by artist, A-Z.
	case artist

	/// Newest release first; items without a release date come last.
	case released

	public var id: String { self.rawValue }
}

/// The lyrics format accepted by `Library.setLyrics(id:content:format:)`.
public enum LyricsFormat: String, Codable, Sendable {
	/// Plain, unsynced lyrics text.
	case plain

	/// LRC-formatted synced lyrics.
	case lrc
}

struct RecordRecentlyPlayedRequest: Encodable, Sendable {
	let type: RecentEntryKind
	let refId: String
}

struct EditTrackMetadataRequest: Encodable, Sendable {
	let title: String?
	let artistName: String?
	let album: Patchable<String>
	let albumType: Patchable<AlbumKind>
	let releaseDate: Patchable<Double>
	let duration: Double?
	let label: Patchable<String>
	let trackNumber: Patchable<Double>
	let coverArt: Patchable<String>

	private enum CodingKeys: String, CodingKey {
		case title, artistName, album, albumType, releaseDate, duration, label, trackNumber, coverArt
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(title, forKey: .title)
		try container.encodeIfPresent(artistName, forKey: .artistName)
		try container.encodeIfPresent(duration, forKey: .duration)
		switch album {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .album)
			case .value(let value): try container.encode(value, forKey: .album)
		}
		switch albumType {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .albumType)
			case .value(let value): try container.encode(value, forKey: .albumType)
		}
		switch releaseDate {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .releaseDate)
			case .value(let value): try container.encode(value, forKey: .releaseDate)
		}
		switch label {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .label)
			case .value(let value): try container.encode(value, forKey: .label)
		}
		switch trackNumber {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .trackNumber)
			case .value(let value): try container.encode(value, forKey: .trackNumber)
		}
		switch coverArt {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .coverArt)
			case .value(let value): try container.encode(value, forKey: .coverArt)
		}
	}
}

struct ChangeTrackAlbumRequest: Encodable, Sendable {
	let albumId: String
}

struct SetTrackLyricsRequest: Encodable, Sendable {
	let content: String
	let format: LyricsFormat
}

struct SetLyricsOffsetRequest: Encodable, Sendable {
	let offsetMs: Int
}
