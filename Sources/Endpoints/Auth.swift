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

	public var path: String {
		switch self {
			case .login:
				return "/api/v1/auth/login"
			case .register:
				return "/api/v1/auth/register"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .login, .register:
				return [.post]
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .login(let username, let password):
				return AnyEncodable(LoginRequest(username: username, password: password))
			case .register(let username, let password, let token):
				return AnyEncodable(RegisterRequest(username: username, password: password, token: token))
		}
	}
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
