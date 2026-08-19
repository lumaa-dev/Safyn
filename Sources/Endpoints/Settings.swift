// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/settings` path.
public enum Settings: NafynEndpoint {

	/// List active (unused, unexpired) registration tokens. Requires `manageAccounts`.
	///
	/// Returns `[`` RegisterTokenRow``]`.
	case registerTokens

	/// Create a one-time, 4-hour-lived registration token that unlocks `Auth.register` when open registration is disabled. Requires `manageAccounts`.
	///
	/// Returns ``RegisterTokenRow``.
	case createRegisterToken

	/// Whether open registration is currently allowed (no token required at ``Auth/register(username:password:token:)``). Public, no authentication needed.
	///
	/// Returns ``RegistrationOpenResponse``.
	case registrationOpen

	/// Open or close public registration. Requires `manageAccounts`.
	///
	/// Returns ``RegistrationOpenResponse``.
	case setRegistrationOpen(open: Bool)

	/// Disk and per-user storage usage stats for the server's music directory. Requires `manageMusic`.
	///
	/// Returns ``StorageInfo``.
	case storage

	public var path: String {
		switch self {
			case .registerTokens, .createRegisterToken:
				return "/api/v1/settings/register-tokens"
			case .registrationOpen, .setRegistrationOpen:
				return "/api/v1/settings/register"
			case .storage:
				return "/api/v1/settings/storage"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .registerTokens, .registrationOpen, .storage:
				return [.get]
			case .createRegisterToken:
				return [.post]
			case .setRegistrationOpen:
				return [.patch]
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .setRegistrationOpen(let open):
				return AnyEncodable(SetRegistrationOpenRequest(open: open))
			default:
				return nil
		}
	}
}

struct SetRegistrationOpenRequest: Encodable, Sendable {
	let open: Bool
}
