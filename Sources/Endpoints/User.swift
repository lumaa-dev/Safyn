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
	///   - listenBrainz: Up to 50 characters. Use `.clear` to unlink, `.value(_:)` to set, or leave `.unset` to not change it.
	///   - discogs: Up to 50 characters. Use `.clear` to unlink, `.value(_:)` to set, or leave `.unset` to not change it.
	case updateProfile(displayName: String? = nil, listenBrainz: Patchable<String> = .unset, discogs: Patchable<String> = .unset)

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

	/// List the currently authenticated user's own registered passkeys. Public keys are never returned.
	///
	/// Returns `[`` PasskeySummary``]`.
	case passkeys

	/// Remove one of the currently authenticated user's own passkeys.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``. Fails with a 404 if `id`
	/// isn't one of your passkeys.
	/// - Parameter id: Passkey ID, from ``PasskeySummary/id``.
	case deletePasskey(id: String)

	/// Start registering a new passkey for the currently authenticated user: returns options to pass
	/// into the browser's `navigator.credentials.create()`.
	///
	/// Returns an untyped ``JSONValue`` — send this with ``NafynServer/send(_:)`` and decode the shape
	/// your WebAuthn library expects. Fails with a 400 if the passkey limit has been reached.
	case passkeyRegisterOptions

	/// Finish registering a new passkey: verifies the browser's `navigator.credentials.create()`
	/// response against the challenge from ``passkeyRegisterOptions`` and stores the credential.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``.
	/// - Parameters:
	///   - response: The `RegistrationResponseJSON` from the browser's `startRegistration()`.
	///   - label: An optional user-assigned label for the passkey.
	case registerPasskey(response: JSONValue, label: String? = nil)

	/// Full export of everything the instance holds about the currently authenticated user: profile,
	/// settings, session/login metadata, credential metadata (never secrets), library entries,
	/// playlists, download requests, recently played, and all listening data. Always scoped to the
	/// caller — there is no parameter for exporting anyone else's account.
	///
	/// Returns raw `Data` — send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// Fails with a 429 if exported too often.
	case exportAccountData

	/// Get the currently authenticated user's own playback preferences (crossfade).
	///
	/// Returns ``PlaybackSettings``.
	case playbackSettings

	/// Update the currently authenticated user's own playback preferences. Only the provided fields are
	/// changed.
	///
	/// Returns ``PlaybackSettings``.
	/// - Parameters:
	///   - crossfadeEnabled: Whether crossfade is enabled.
	///   - crossfadeMs: Crossfade length in milliseconds, clamped to 500-12000 server-side.
	case updatePlaybackSettings(crossfadeEnabled: Bool? = nil, crossfadeMs: Int? = nil)

	/// List the Apple devices (APNs tokens) the Nafyn iOS app registered for the requesting user.
	/// Tokens themselves are never returned.
	///
	/// Returns `[`` AppleDevice``]`.
	case devices

	/// Register (or refresh) an APNs token from the Nafyn iOS app. The token is bound to the login making
	/// the request: logging that session out, or revoking it, unregisters it. Call again on every launch
	/// and whenever a token changes. Fails with a 409 when the device limit is reached.
	///
	/// Returns ``AppleDevice``.
	/// - Parameters:
	///   - token: Hex-encoded APNs token.
	///   - kind: What the token is for. `.alert` is the regular device token; the rest are push-to-start tokens.
	///   - environment: APNs gateway: sandbox for Xcode builds, production for TestFlight/App Store. Defaults to production server-side.
	///   - deviceName: Up to 100 characters.
	///   - events: Alert events this device wants. Use `.clear` for every event, `.value(_:)` to filter, or leave `.unset` to omit it.
	case registerDevice(token: String, kind: AppleDeviceKind, environment: APNsEnvironment? = nil, deviceName: Patchable<String> = .unset, events: Patchable<[String]> = .unset)

	/// Unregister one of the requesting user's Apple device tokens. That device stops receiving pushes of
	/// that kind until the app registers again.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``. Fails with a 404 if `id` isn't yours.
	/// - Parameter id: Device ID, from ``AppleDevice/id``.
	case deleteDevice(id: String)

	/// Register the update token of a running Live Activity or Now Playing remote session, so the server
	/// can update and end it. The referenced item must belong to the caller.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``.
	/// - Parameters:
	///   - kind: What the activity belongs to.
	///   - refId: The request ID (`.request`), release subscription ID (`.release`) or the remote session's `attributes.id` (`.nowPlaying`).
	///   - token: Hex-encoded activity push token.
	///   - environment: Defaults to production server-side.
	case registerActivityToken(kind: ActivityKind, refId: String, token: String, environment: APNsEnvironment? = nil)

	/// List the requesting user's own webhooks. URLs are never returned, only their host.
	///
	/// Returns `[`` WebhookSummary``]`.
	case webhooks

	/// Add a webhook to the requesting user's own webhooks. The URL is checked (https, public address)
	/// before it is stored, and its service is auto-detected unless `format` says otherwise.
	///
	/// Returns ``WebhookSummary``.
	/// - Parameters:
	///   - name: Up to 100 characters.
	///   - url: https only. Private/LAN addresses are refused.
	///   - format: Defaults to auto-detection from the URL.
	///   - events: Use `.clear` for every event, `.value(_:)` to filter, or leave `.unset` to omit it.
	///   - enabled: Whether the webhook is enabled.
	case createWebhook(name: String? = nil, url: String? = nil, format: WebhookFormat? = nil, events: Patchable<[WebhookEvent]> = .unset, enabled: Bool? = nil)

	/// Edit one of the requesting user's own webhooks. Every field is optional; re-enabling a webhook that
	/// was switched off after repeated failures clears its failure count.
	///
	/// Returns ``WebhookSummary``.
	/// - Parameters:
	///   - id: Webhook ID.
	///   - name: Up to 100 characters.
	///   - url: https only. Private/LAN addresses are refused.
	///   - format: The service to deliver to.
	///   - events: Use `.clear` for every event, `.value(_:)` to filter, or leave `.unset` to not change it.
	///   - enabled: Whether the webhook is enabled.
	case updateWebhook(id: String, name: String? = nil, url: String? = nil, format: WebhookFormat? = nil, events: Patchable<[WebhookEvent]> = .unset, enabled: Bool? = nil)

	/// Delete one of the requesting user's own webhooks.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``.
	/// - Parameter id: Webhook ID.
	case deleteWebhook(id: String)

	/// Send a sample message to one of the requesting user's own webhooks and report what the receiving service answered.
	///
	/// Returns ``WebhookTestResponse``.
	/// - Parameter id: Webhook ID.
	case testWebhook(id: String)

	/// Permanently erase the requesting user's own account and every piece of data attached to it.
	/// **Irreversible.**
	///
	/// Requires re-authentication. Fails with a 401 on a wrong password, a 409 if this is the instance's
	/// last administrator while other accounts still exist, and a 429 on too many attempts.
	///
	/// Returns ``AccountErasedResponse``.
	/// - Parameter password: The account's current password, or one of its API tokens.
	case deleteAccount(password: String)

	/// The user's ListenBrainz connection (scrobbling).
	///
	/// Returns ``ListenBrainzConnection``.
	case listenBrainz

	/// Connect a ListenBrainz account with its user token (from listenbrainz.org/settings). The server checks the
	/// token with ListenBrainz, keeps it and turns scrobbling on; connecting again replaces the account. A 400 means
	/// ListenBrainz doesn't accept the token, a 502 that ListenBrainz couldn't be reached.
	///
	/// Returns ``ListenBrainzConnection``.
	/// - Parameter token: The ListenBrainz user token.
	case connectListenBrainz(token: String)

	/// Pause or resume scrobbling to the connected ListenBrainz account (404 when none is connected).
	///
	/// Returns ``ListenBrainzConnection``.
	case updateListenBrainz(scrobbling: Bool)

	/// Disconnect the ListenBrainz account: Nafyn forgets its token.
	///
	/// Returns ``RemovedResponse``.
	case disconnectListenBrainz

	/// Tell ListenBrainz what the user just started playing, when scrobbling is on (fire-and-forget on the server).
	/// The listen itself comes from the play event (`Insights.ingestEvents`).
	///
	/// Returns nothing meaningful — send this with ``NafynServer/sendRaw(_:)``.
	/// - Parameter mediaId: The Nafyn media ID of the track.
	case listenBrainzNowPlaying(mediaId: String)

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
			case .passkeys:
				return "/api/v1/user/passkeys"
			case .deletePasskey(let id):
				return "/api/v1/user/passkeys/\(id)"
			case .passkeyRegisterOptions:
				return "/api/v1/user/passkeys/register-options"
			case .registerPasskey:
				return "/api/v1/user/passkeys/register"
			case .exportAccountData:
				return "/api/v1/user/export"
			case .playbackSettings, .updatePlaybackSettings:
				return "/api/v1/user/playback-settings"
			case .devices, .registerDevice:
				return "/api/v1/user/devices"
			case .deleteDevice(let id):
				return "/api/v1/user/devices/\(id)"
			case .registerActivityToken:
				return "/api/v1/user/activities"
			case .webhooks, .createWebhook:
				return "/api/v1/user/webhooks"
			case .updateWebhook(let id, _, _, _, _, _), .deleteWebhook(let id):
				return "/api/v1/user/webhooks/\(id)"
			case .testWebhook(let id):
				return "/api/v1/user/webhooks/\(id)/test"
			case .deleteAccount:
				return "/api/v1/user/me"
			case .listenBrainz, .connectListenBrainz, .updateListenBrainz, .disconnectListenBrainz:
				return "/api/v1/user/listenbrainz"
			case .listenBrainzNowPlaying:
				return "/api/v1/user/listenbrainz/now-playing"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .avatar, .me, .apiTokens, .appearanceSettings, .sessions, .unitySettings, .passkeys, .exportAccountData, .playbackSettings, .devices, .webhooks, .listenBrainz:
				return [.get]
			case .deleteAvatar, .deleteApiToken, .deleteSession, .deletePasskey, .deleteDevice, .deleteWebhook, .deleteAccount, .disconnectListenBrainz:
				return [.delete]
			case .setAvatar, .createApiToken, .passkeyRegisterOptions, .registerPasskey, .registerDevice, .registerActivityToken, .createWebhook, .testWebhook, .connectListenBrainz, .listenBrainzNowPlaying:
				return [.post]
			case .updateProfile, .updateAppearanceSettings, .updateUnitySettings, .updatePlaybackSettings, .updateWebhook, .updateListenBrainz:
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
			case .updateProfile(let displayName, let listenBrainz, let discogs):
				return AnyEncodable(UpdateMyProfileRequest(displayName: displayName, listenBrainz: listenBrainz, discogs: discogs))
			case .createApiToken(let name):
				return AnyEncodable(CreateApiTokenRequest(name: name))
			case .updateAppearanceSettings(let showFileSize, let showDuration):
				return AnyEncodable(UpdateAppearanceSettingsRequest(showFileSize: showFileSize, showDuration: showDuration))
			case .updateUnitySettings(let enabled):
				return AnyEncodable(UnitySettings(enabled: enabled))
			case .registerPasskey(let response, let label):
				return AnyEncodable(RegisterPasskeyRequest(response: response, label: label))
			case .updatePlaybackSettings(let crossfadeEnabled, let crossfadeMs):
				return AnyEncodable(UpdatePlaybackSettingsRequest(crossfadeEnabled: crossfadeEnabled, crossfadeMs: crossfadeMs))
			case .registerDevice(let token, let kind, let environment, let deviceName, let events):
				return AnyEncodable(RegisterDeviceRequest(token: token, kind: kind, environment: environment, deviceName: deviceName, events: events))
			case .registerActivityToken(let kind, let refId, let token, let environment):
				return AnyEncodable(RegisterActivityTokenRequest(kind: kind, refId: refId, token: token, environment: environment))
			case .createWebhook(let name, let url, let format, let events, let enabled),
				.updateWebhook(_, let name, let url, let format, let events, let enabled):
				return AnyEncodable(WebhookInput(name: name, url: url, format: format, events: events, enabled: enabled))
			case .deleteAccount(let password):
				return AnyEncodable(DeleteAccountRequest(password: password))
			case .connectListenBrainz(let token):
				return AnyEncodable(ConnectListenBrainzRequest(token: token))
			case .updateListenBrainz(let scrobbling):
				return AnyEncodable(UpdateListenBrainzRequest(scrobbling: scrobbling))
			case .listenBrainzNowPlaying(let mediaId):
				return AnyEncodable(ListenBrainzNowPlayingRequest(mediaId: mediaId))
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

struct DeleteAccountRequest: Encodable, Sendable {
	let password: String
}

struct ConnectListenBrainzRequest: Encodable, Sendable {
	let token: String
}

struct UpdateListenBrainzRequest: Encodable, Sendable {
	let scrobbling: Bool
}

struct ListenBrainzNowPlayingRequest: Encodable, Sendable {
	let mediaId: String
}

struct RegisterActivityTokenRequest: Encodable, Sendable {
	let kind: ActivityKind
	let refId: String
	let token: String
	let environment: APNsEnvironment?
}

struct RegisterDeviceRequest: Encodable, Sendable {
	let token: String
	let kind: AppleDeviceKind
	let environment: APNsEnvironment?
	let deviceName: Patchable<String>
	let events: Patchable<[String]>

	private enum CodingKeys: String, CodingKey {
		case token, kind, environment, deviceName, events
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encode(token, forKey: .token)
		try container.encode(kind, forKey: .kind)
		try container.encodeIfPresent(environment, forKey: .environment)
		switch deviceName {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .deviceName)
			case .value(let value): try container.encode(value, forKey: .deviceName)
		}
		switch events {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .events)
			case .value(let value): try container.encode(value, forKey: .events)
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

struct RegisterPasskeyRequest: Encodable, Sendable {
	let response: JSONValue
	let label: String?
}

struct UpdatePlaybackSettingsRequest: Encodable, Sendable {
	let crossfadeEnabled: Bool?
	let crossfadeMs: Int?
}

struct UpdateMyProfileRequest: Encodable, Sendable {
	let displayName: String?
	let listenBrainz: Patchable<String>
	let discogs: Patchable<String>

	private enum CodingKeys: String, CodingKey {
		case displayName, listenBrainz, discogs
	}

	func encode(to encoder: Encoder) throws {
		var container = encoder.container(keyedBy: CodingKeys.self)
		try container.encodeIfPresent(displayName, forKey: .displayName)
		switch listenBrainz {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .listenBrainz)
			case .value(let value): try container.encode(value, forKey: .listenBrainz)
		}
		switch discogs {
			case .unset: break
			case .clear: try container.encodeNil(forKey: .discogs)
			case .value(let value): try container.encode(value, forKey: .discogs)
		}
	}
}
