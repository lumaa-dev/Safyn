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

	/// List the instance's global webhooks. Requires `manageWebhooks`. URLs are never returned, only their host.
	///
	/// Returns `[`` WebhookSummary``]`.
	case webhooks

	/// Add a webhook to the instance's global webhooks. Requires `manageWebhooks`. The URL is checked
	/// (https, public address) before it is stored, and its service is auto-detected unless `format` says otherwise.
	///
	/// Returns ``WebhookSummary``.
	/// - Parameters:
	///   - name: Up to 100 characters.
	///   - url: https only. Private/LAN addresses are refused unless the server allows them.
	///   - format: Defaults to auto-detection from the URL.
	///   - events: Use `.clear` for every event, `.value(_:)` to filter, or leave `.unset` to omit it.
	///   - enabled: Whether the webhook is enabled.
	case createWebhook(name: String? = nil, url: String? = nil, format: WebhookFormat? = nil, events: Patchable<[WebhookEvent]> = .unset, enabled: Bool? = nil)

	/// Edit one of the instance's global webhooks. Requires `manageWebhooks`. Every field is optional;
	/// re-enabling a webhook that was switched off after repeated failures clears its failure count.
	///
	/// Returns ``WebhookSummary``.
	/// - Parameters:
	///   - id: Webhook ID.
	///   - name: Up to 100 characters.
	///   - url: https only.
	///   - format: The service to deliver to.
	///   - events: Use `.clear` for every event, `.value(_:)` to filter, or leave `.unset` to not change it.
	///   - enabled: Whether the webhook is enabled.
	case updateWebhook(id: String, name: String? = nil, url: String? = nil, format: WebhookFormat? = nil, events: Patchable<[WebhookEvent]> = .unset, enabled: Bool? = nil)

	/// Delete one of the instance's global webhooks. Requires `manageWebhooks`.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``.
	/// - Parameter id: Webhook ID.
	case deleteWebhook(id: String)

	/// Send a sample message to one of the instance's global webhooks, whatever its enabled flag and event
	/// filter, and report what the receiving service answered. Requires `manageWebhooks`.
	///
	/// Returns ``WebhookTestResponse``.
	/// - Parameter id: Webhook ID.
	case testWebhook(id: String)

	public var path: String {
		switch self {
			case .registerTokens, .createRegisterToken:
				return "/api/v1/settings/register-tokens"
			case .registrationOpen, .setRegistrationOpen:
				return "/api/v1/settings/register"
			case .storage:
				return "/api/v1/settings/storage"
			case .webhooks, .createWebhook:
				return "/api/v1/webhooks"
			case .updateWebhook(let id, _, _, _, _, _), .deleteWebhook(let id):
				return "/api/v1/webhooks/\(id)"
			case .testWebhook(let id):
				return "/api/v1/webhooks/\(id)/test"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .registerTokens, .registrationOpen, .storage, .webhooks:
				return [.get]
			case .createRegisterToken, .createWebhook, .testWebhook:
				return [.post]
			case .deleteWebhook:
				return [.delete]
			case .setRegistrationOpen, .updateWebhook:
				return [.patch]
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .setRegistrationOpen(let open):
				return AnyEncodable(SetRegistrationOpenRequest(open: open))
			case .createWebhook(let name, let url, let format, let events, let enabled),
				.updateWebhook(_, let name, let url, let format, let events, let enabled):
				return AnyEncodable(WebhookInput(name: name, url: url, format: format, events: events, enabled: enabled))
			default:
				return nil
		}
	}
}

struct SetRegistrationOpenRequest: Encodable, Sendable {
	let open: Bool
}
