// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/auth/` path.
public enum Auth: NafynEndpoint {

	/// Log in as a user using their username and password.
	///
	/// Returns ``AuthResponse``.
	case login(username: String, password: String)

	/// Create a new user.
	///
	/// Returns ``AuthResponse``.
	/// - Parameter token: A registration token, required only when open registration is disabled. See ``Settings/registerTokens``.
	case register(username: String, password: String, token: String? = nil)

	/// Revoke the currently authenticated session (the one making this request), signing this device out server-side.
	///
	/// The response has no body — send this with ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// Afterwards, clear ``NafynServer/authToken``; the token is rejected on its next request.
	case logout

	/// Start a passkey login: returns options to pass into the browser's `navigator.credentials.get()`,
	/// plus a challenge ID to send back to ``passkeyLogin(challengeId:response:)``. No username needed —
	/// the credential is discoverable.
	///
	/// Returns an untyped ``JSONValue`` — send this with ``NafynServer/send(_:)`` and decode the shape your
	/// WebAuthn library expects.
	case passkeyLoginOptions

	/// Finish a passkey login: verifies the browser's `navigator.credentials.get()` response against the
	/// challenge from ``passkeyLoginOptions`` and, if valid, logs the owning user in.
	///
	/// Returns ``AuthResponse``.
	/// - Parameters:
	///   - challengeId: The challenge ID from ``passkeyLoginOptions``.
	///   - response: The `AuthenticationResponseJSON` from the browser's `startAuthentication()`.
	case passkeyLogin(challengeId: String, response: JSONValue)

	public var path: String {
		switch self {
			case .login:
				return "/api/v1/auth/login"
			case .register:
				return "/api/v1/auth/register"
			case .logout:
				return "/api/v1/auth/logout"
			case .passkeyLoginOptions:
				return "/api/v1/auth/passkey/login-options"
			case .passkeyLogin:
				return "/api/v1/auth/passkey/login"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .login, .register, .logout, .passkeyLoginOptions, .passkeyLogin:
				return [.post]
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .login(let username, let password):
				return AnyEncodable(LoginRequest(username: username, password: password))
			case .register(let username, let password, let token):
				return AnyEncodable(RegisterRequest(username: username, password: password, token: token))
			case .logout, .passkeyLoginOptions:
				return nil
			case .passkeyLogin(let challengeId, let response):
				return AnyEncodable(PasskeyLoginRequest(challengeId: challengeId, response: response))
		}
	}
}

struct PasskeyLoginRequest: Encodable, Sendable {
	let challengeId: String
	let response: JSONValue
}

struct LoginRequest: Encodable, Sendable {
	let username: String
	let password: String
}

struct RegisterRequest: Encodable, Sendable {
	let username: String
	let password: String
	let token: String?
}
