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

	/// List the currently authenticated user's own API tokens (app passwords, currently used for
	/// Subsonic auth). The token value itself is never returned here — only at creation time.
	///
	/// Returns `[`` ApiTokenSummary``]`.
	case apiTokens

	/// Create a new API token (app password) for the currently authenticated user — currently used for
	/// Subsonic auth. The plaintext token value is only ever returned in this response; it can't be
	/// retrieved again afterward.
	///
	/// Returns ``CreateApiTokenResponse``.
	/// - Parameter name: An optional user-assigned label for the token.
	case createApiToken(name: String? = nil)

	/// Revoke one of the currently authenticated user's own API tokens.
	///
	/// - Parameter id: API token ID.
	case deleteApiToken(id: String)

	/// Get the currently authenticated user's own display preferences (file size / duration visibility
	/// in track lists).
	///
	/// Returns ``AppearanceSettings``.
	case appearanceSettings

	/// Update the currently authenticated user's own display preferences. Only the provided fields are changed.
	///
	/// Returns ``AppearanceSettings``.
	/// - Parameters:
	///   - showFileSize: Whether track lists should show file size. Turning this on without `manageMusic`/`admin`
	///     is silently ignored, not rejected.
	///   - showDuration: Whether track lists should show duration.
	case updateAppearanceSettings(showFileSize: Bool? = nil, showDuration: Bool? = nil)

	/// List the currently authenticated user's own active login sessions, one per device/login.
	///
	/// Returns `[`` SessionSummary``]`.
	case sessions

	/// Revoke one of the currently authenticated user's own login sessions, signing that device out.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``. Fails with a 404 if `id`
	/// isn't one of your sessions. To revoke the calling session itself, prefer ``Auth/logout``.
	/// - Parameter id: Session ID, from ``SessionSummary/id``.
	case deleteSession(id: String)

	/// Get the currently authenticated user's Nafyn Unity preference.
	///
	/// Returns ``UnitySettings``.
	case unitySettings

	/// Turn Nafyn Unity on or off account-wide for the currently authenticated user.
	///
	/// The server does not check this when a Unity socket opens, so it only gates UI — see ``NafynUnitySocket``.
	///
	/// Returns ``UnitySettings``.
	case updateUnitySettings(enabled: Bool)

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
			case .apiTokens, .createApiToken:
				return "/api/v1/user/tokens"
			case .deleteApiToken(let id):
				return "/api/v1/user/tokens/\(id)"
			case .appearanceSettings, .updateAppearanceSettings:
				return "/api/v1/user/appearance-settings"
			case .sessions:
				return "/api/v1/user/sessions"
			case .deleteSession(let id):
				return "/api/v1/user/sessions/\(id)"
			case .unitySettings, .updateUnitySettings:
				return "/api/v1/user/unity-settings"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .avatar, .me, .apiTokens, .appearanceSettings, .sessions, .unitySettings:
				return [.get]
			case .deleteAvatar, .deleteApiToken, .deleteSession:
				return [.delete]
			case .setAvatar, .createApiToken:
				return [.post]
			case .updateProfile, .updateAppearanceSettings, .updateUnitySettings:
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
			case .createApiToken(let name):
				return AnyEncodable(CreateApiTokenRequest(name: name))
			case .updateAppearanceSettings(let showFileSize, let showDuration):
				return AnyEncodable(UpdateAppearanceSettingsRequest(showFileSize: showFileSize, showDuration: showDuration))
			case .updateUnitySettings(let enabled):
				return AnyEncodable(UnitySettings(enabled: enabled))
			default:
				return nil
		}
	}

	public var multipart: [MultipartPart]? {
		switch self {
			case .setAvatar(let data, let filename, let mimeType):
				return [.file(fieldName: "avatar", filename: filename, mimeType: mimeType, data: data)]
			default:
				return nil
		}
	}
}

struct CreateApiTokenRequest: Encodable, Sendable {
	let name: String?
}

struct UpdateAppearanceSettingsRequest: Encodable, Sendable {
	let showFileSize: Bool?
	let showDuration: Bool?
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
