// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/users` path — admin actions on other users.
///
/// For self-service actions on the requesting user's own account, see ``User``.
public enum Users: NafynEndpoint {

	/// Permanently erase a user account and every piece of data attached to it (sessions, tokens, passkeys,
	/// settings, library entries, playlists, listening data). Download requests they made are kept without
	/// the requester. Requires `admin`, or `manageAccounts` against a non-privileged target.
	///
	/// Returns ``AccountErasedResponse``.
	/// - Parameter id: Target user ID.
	case delete(id: String)

	/// Update another user's account fields, including permissions.
	///
	/// Requires `admin`, or `manageAccounts` against a non-privileged target. Only an `admin` can grant/revoke `manageAccounts` or `admin` itself. Returns ``NafynUser``.
	/// - Parameters:
	///   - id: Target user ID.
	///   - displayName: 1-20 characters.
	///   - lastFm: Up to 50 characters. Use `.clear` to unlink, `.value(_:)` to set, or leave `.unset` to not change it.
	///   - discogs: Up to 50 characters. Use `.clear` to unlink, `.value(_:)` to set, or leave `.unset` to not change it.
	///   - permissions: The new permission bitfield, replacing the target's current one entirely.
	case update(id: String, displayName: String? = nil, username: String? = nil, lastFm: Patchable<String> = .unset, discogs: Patchable<String> = .unset, permissions: Permissions? = nil)

	/// Upload/replace another user's avatar. Requires `admin`, or `manageAccounts` against a non-privileged target.
	///
	/// Returns ``NafynUser``.
	/// - Parameters:
	///   - id: Target user ID.
	///   - data: The image's raw bytes.
	///   - filename: Reported in the upload's `Content-Disposition` header. Defaults to `"avatar.webp"`.
	///   - mimeType: The image's MIME type. Defaults to `"image/webp"`.
	case setAvatar(id: String, data: Data, filename: String = "avatar.webp", mimeType: String = "image/webp")

	/// List every user account, paginated. Requires `manageAccounts`.
	///
	/// Returns `[`` NafynUser``]`. The spec doesn't detail a pagination envelope for this endpoint,
	/// so this decodes as a bare array; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - limit: Maximum number of results to return.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	case all(limit: Int? = nil, offset: Int? = nil)

	public var path: String {
		switch self {
			case .delete(let id), .update(let id, _, _, _, _, _):
				return "/api/v1/users/\(id)"
			case .setAvatar(let id, _, _, _):
				return "/api/v1/users/\(id)/avatar"
			case .all:
				return "/api/v1/users"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .delete:
				return [.delete]
			case .update:
				return [.patch]
			case .setAvatar:
				return [.post]
			case .all:
				return [.get]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .all(let limit, let offset):
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
			case .update(_, let displayName, let username, let lastFm, let discogs, let permissions):
				return AnyEncodable(UpdateUserRequest(displayName: displayName, username: username, lastFm: lastFm, discogs: discogs, permissions: permissions))
			default:
				return nil
		}
	}

	public var multipart: [MultipartPart]? {
		switch self {
			case .setAvatar(_, let data, let filename, let mimeType):
				return [.file(fieldName: "avatar", filename: filename, mimeType: mimeType, data: data)]
			default:
				return nil
		}
	}
}

struct UpdateUserRequest: Encodable, Sendable {
	let displayName: String?
	let username: String?
	let lastFm: Patchable<String>
	let discogs: Patchable<String>
	let permissions: Permissions?

	private enum CodingKeys: String, CodingKey {
		case displayName, username, lastFm, discogs, permissions
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(displayName, forKey: .displayName)
		try container.encodeIfPresent(username, forKey: .username)
		switch lastFm {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .lastFm)
			case .value(let value): try container.encode(value, forKey: .lastFm)
		}
		switch discogs {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .discogs)
			case .value(let value): try container.encode(value, forKey: .discogs)
		}
		try container.encodeIfPresent(permissions, forKey: .permissions)
	}
}
