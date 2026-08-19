// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/user` path — self-service actions on the requesting user's own account.
///
/// For admin actions on other users, see ``Users``.
public enum User: NafynEndpoint {

	/// Serve a user's avatar image (`image/webp`). Any authenticated user can view any other user's avatar.
	///
	/// Returns raw `Data` — send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// - Parameters:
	///   - id: User ID.
	///   - token: Auth token, as a fallback for clients that can't set the Authorization header (e.g. `<img>` elements).
	case avatar(id: String, token: String? = nil)

	/// Remove the currently authenticated user's own avatar.
	///
	/// Returns ``NafynUser``.
	case deleteAvatar

	/// Upload/replace the currently authenticated user's own avatar.
	///
	/// Returns ``NafynUser``.
	/// - Parameters:
	///   - data: The image's raw bytes.
	///   - filename: Reported in the upload's `Content-Disposition` header. Defaults to `"avatar.webp"`.
	///   - mimeType: The image's MIME type. Defaults to `"image/webp"`.
	case setAvatar(data: Data, filename: String = "avatar.webp", mimeType: String = "image/webp")

	/// Get the currently authenticated user's own profile.
	///
	/// Returns ``NafynUser``.
	case me

	/// Update the currently authenticated user's own profile fields. Only the provided fields are changed.
	///
	/// Returns ``NafynUser``.
	/// - Parameters:
	///   - displayName: 1-20 characters.
	///   - lastFm: Up to 50 characters. Use `.clear` to unlink, `.value(_:)` to set, or leave `.unset` to not change it.
	///   - discogs: Up to 50 characters. Use `.clear` to unlink, `.value(_:)` to set, or leave `.unset` to not change it.
	case updateProfile(displayName: String? = nil, lastFm: Patchable<String> = .unset, discogs: Patchable<String> = .unset)

	public var path: String {
		switch self {
			case .avatar(let id, _):
				return "/api/v1/user/\(id)/avatar"
			case .deleteAvatar, .setAvatar:
				return "/api/v1/user/avatar"
			case .me:
				return "/api/v1/user/me"
			case .updateProfile:
				return "/api/v1/user/profile"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .avatar, .me:
				return [.get]
			case .deleteAvatar:
				return [.delete]
			case .setAvatar:
				return [.post]
			case .updateProfile:
				return [.patch]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .avatar(_, let token):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
			default:
				return []
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .updateProfile(let displayName, let lastFm, let discogs):
				return AnyEncodable(UpdateMyProfileRequest(displayName: displayName, lastFm: lastFm, discogs: discogs))
			default:
				return nil
		}
	}

	public var multipart: MultipartFile? {
		switch self {
			case .setAvatar(let data, let filename, let mimeType):
				return MultipartFile(fieldName: "avatar", filename: filename, mimeType: mimeType, data: data)
			default:
				return nil
		}
	}
}

struct UpdateMyProfileRequest: Encodable, Sendable {
	let displayName: String?
	let lastFm: Patchable<String>
	let discogs: Patchable<String>

	private enum CodingKeys: String, CodingKey {
		case displayName, lastFm, discogs
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(displayName, forKey: .displayName)
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
	}
}
