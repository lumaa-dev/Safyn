// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/playlist` path.
public enum Playlist: NafynEndpoint {

	/// Delete a playlist and its image. Owner only.
	///
	/// Returns ``RemovedResponse``.
	case delete(pid: String)

	/// Get playlist details: metadata, owner, members, and entries.
	///
	/// Public playlists are readable by anonymous visitors (no `authToken` required); private ones
	/// require owner/member access. Returns ``PlaylistDetail``.
	case get(pid: String)

	/// Update a playlist's details (owner-only) and/or `sortMode` (owner or any invited member). Only the provided fields are changed.
	///
	/// Returns ``PlaylistRow``.
	/// - Parameters:
	///   - title: 1-100 characters. Owner only.
	///   - description: Owner only. Use `.clear` to remove an existing description, `.value(_:)` to set one, or leave `.unset` to not change it.
	///   - privacy: Owner only.
	///   - sortMode: Owner or any invited member.
	case update(pid: String, title: String? = nil, description: Patchable<String> = .unset, privacy: PlaylistPrivacy? = nil, sortMode: PlaylistSortMode? = nil)

	/// Remove a playlist's cover image. Owner only.
	///
	/// Returns ``PlaylistRow``.
	case deleteImage(pid: String)

	/// Serve a playlist's cover image (`image/webp`).
	///
	/// Public for public playlists; private ones require owner/member access. Returns raw `Data` —
	/// send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// - Parameter token: Auth token, as a fallback for clients that can't set the Authorization header (only needed for private playlists).
	case image(pid: String, token: String? = nil)

	/// Upload/replace a playlist's cover image. Owner only.
	///
	/// Returns ``PlaylistRow``.
	/// - Parameters:
	///   - data: The image's raw bytes.
	///   - filename: Reported in the upload's `Content-Disposition` header. Defaults to `"image.webp"`.
	///   - mimeType: The image's MIME type. Defaults to `"image/webp"`.
	case setImage(pid: String, data: Data, filename: String = "image.webp", mimeType: String = "image/webp")

	/// Voluntarily leave a playlist you're a member of. Tracks you added stay in the playlist.
	///
	/// The owner can't leave their own playlist (use ``delete(pid:)`` instead). Returns ``RemovedResponse``.
	case leave(pid: String)

	/// Invite a member to a playlist by username. Owner only.
	///
	/// Returns ``PlaylistMemberRow``.
	case addMember(pid: String, username: String)

	/// Remove a member from a playlist. Owner only (members leave voluntarily via ``leave(pid:)`` instead).
	///
	/// Returns ``RemovedResponse``.
	/// - Parameter uid: ID of the member to remove.
	case removeMember(pid: String, uid: String)

	/// Manually reorder a playlist's entries. Owner only.
	///
	/// Returns ``ReorderedResponse``.
	/// - Parameter order: Every entry ID currently in the playlist, in the desired order.
	case reorder(pid: String, order: [String])

	/// Add one or more tracks to a playlist (single track = 1-length array, full album/EP = the album's track IDs).
	///
	/// Owner, invited member, or a user with `manageMusic`. Returns `[`` PlaylistEntryRow``]`.
	/// - Parameter mediaIds: Non-empty array of media IDs to append.
	case addTracks(pid: String, mediaIds: [String])

	/// Remove a single entry from a playlist.
	///
	/// Members may only remove entries they personally added; the owner can remove any entry;
	/// users with `manageMusic` can remove any entry from any playlist. Returns ``RemovedResponse``.
	/// - Parameter eid: Playlist entry ID.
	case removeTrack(pid: String, eid: String)

	/// List a playlist's tracks, paginated. Further pages beyond ``PlaylistDetail``'s first page.
	///
	/// Public playlists are readable by anonymous visitors; private ones require owner/member access.
	/// The spec leaves this endpoint's response schema untyped (no pagination params are documented
	/// either), but it's presumably shaped like ``PlaylistDetail``'s `entries` field — an array of
	/// ``PlaylistEntry`` — or a page of one; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - limit: Maximum number of results to return.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	case tracks(pid: String, limit: Int? = nil, offset: Int? = nil)

	/// List every playlist regardless of owner/membership. Requires `manageMusic`.
	///
	/// Returns `[`` PlaylistRow``]`.
	case all

	/// List playlists owned by, or shared with, the requesting user. Paginated.
	///
	/// Returns `[`` PlaylistRow``]`. The spec doesn't detail a pagination envelope for this endpoint,
	/// so this decodes as a bare array; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - limit: Maximum number of results to return.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	case list(limit: Int? = nil, offset: Int? = nil)

	/// Create a new playlist owned by the requesting user.
	///
	/// Returns ``PlaylistRow``.
	/// - Parameters:
	///   - title: 1-100 characters.
	///   - privacy: Defaults to `.private` server-side when omitted.
	case create(title: String, description: String? = nil, privacy: PlaylistPrivacy? = nil)

	public var path: String {
		switch self {
			case .delete(let pid), .get(let pid), .update(let pid, _, _, _, _):
				return "/api/v1/playlist/\(pid)"
			case .deleteImage(let pid), .image(let pid, _), .setImage(let pid, _, _, _):
				return "/api/v1/playlist/\(pid)/image"
			case .leave(let pid):
				return "/api/v1/playlist/\(pid)/leave"
			case .addMember(let pid, _):
				return "/api/v1/playlist/\(pid)/members"
			case .removeMember(let pid, let uid):
				return "/api/v1/playlist/\(pid)/members/\(uid)"
			case .reorder(let pid, _):
				return "/api/v1/playlist/\(pid)/order"
			case .addTracks(let pid, _), .tracks(let pid, _, _):
				return "/api/v1/playlist/\(pid)/tracks"
			case .removeTrack(let pid, let eid):
				return "/api/v1/playlist/\(pid)/tracks/\(eid)"
			case .all:
				return "/api/v1/playlist/all"
			case .list, .create:
				return "/api/v1/playlist"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .delete, .deleteImage, .removeMember, .removeTrack:
				return [.delete]
			case .get, .image, .all, .list, .tracks:
				return [.get]
			case .update:
				return [.patch]
			case .setImage, .leave, .addMember, .reorder, .addTracks, .create:
				return [.post]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .image(_, let token):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
			case .tracks(_, let limit, let offset), .list(let limit, let offset):
				var items: [URLQueryItem] = []
				if let limit {
					items.append(URLQueryItem(name: "limit", value: String(limit)))
				}
				if let offset {
					items.append(URLQueryItem(name: "offset", value: String(offset)))
				}
				return items
			default:
				return []
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .update(_, let title, let description, let privacy, let sortMode):
				return AnyEncodable(UpdatePlaylistRequest(title: title, description: description, privacy: privacy, sortMode: sortMode))
			case .addMember(_, let username):
				return AnyEncodable(AddPlaylistMemberRequest(username: username))
			case .reorder(_, let order):
				return AnyEncodable(ReorderPlaylistRequest(order: order))
			case .addTracks(_, let mediaIds):
				return AnyEncodable(AddPlaylistTracksRequest(mediaIds: mediaIds))
			case .create(let title, let description, let privacy):
				return AnyEncodable(CreatePlaylistRequest(title: title, description: description, privacy: privacy))
			default:
				return nil
		}
	}

	public var multipart: [MultipartPart]? {
		switch self {
			case .setImage(_, let data, let filename, let mimeType):
				return [.file(fieldName: "image", filename: filename, mimeType: mimeType, data: data)]
			default:
				return nil
		}
	}
}

struct UpdatePlaylistRequest: Encodable, Sendable {
	let title: String?
	let description: Patchable<String>
	let privacy: PlaylistPrivacy?
	let sortMode: PlaylistSortMode?

	private enum CodingKeys: String, CodingKey {
		case title, description, privacy, sortMode
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(title, forKey: .title)
		switch description {
			case .unset:
				break
			case .clear:
				try container.encodeNil(forKey: .description)
			case .value(let value):
				try container.encode(value, forKey: .description)
		}
		try container.encodeIfPresent(privacy, forKey: .privacy)
		try container.encodeIfPresent(sortMode, forKey: .sortMode)
	}
}

struct AddPlaylistMemberRequest: Encodable, Sendable {
	let username: String
}

struct ReorderPlaylistRequest: Encodable, Sendable {
	let order: [String]
}

struct AddPlaylistTracksRequest: Encodable, Sendable {
	let mediaIds: [String]
}

struct CreatePlaylistRequest: Encodable, Sendable {
	let title: String
	let description: String?
	let privacy: PlaylistPrivacy?
}
