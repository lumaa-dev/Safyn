// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/request` path.
public enum Request: NafynEndpoint {

	/// Create a download request for a track or album.
	///
	/// Returns ``NafynRequest``.
	/// - Parameter id: MusicBrainz ID (recording ID for a track, release-group ID for an album).
	case create(id: String, type: RequestKind)

	/// Get a single download request by ID. Only visible to the user who created it, or a user with `manageRequests`.
	///
	/// Returns ``NafynRequest``.
	/// - Parameter id: Request ID.
	case get(id: String)

	/// Update the status of a download request. Requires `manageRequests`.
	///
	/// Returns ``NafynRequest``.
	case updateStatus(requestId: String, status: RequestStatus)

	/// Delete a download request. Only the user who created it, or a user with `manageRequests`, may do this.
	///
	/// Returns nothing meaningful — send this with ``NafynServer/sendRaw(_:)``.
	/// - Parameter id: Request ID.
	case delete(id: String)

	/// List download requests, paginated. Users with `manageRequests` get every request across every
	/// user; others get only their own.
	///
	/// Returns `[`` NafynRequest``]`. The spec doesn't detail a pagination envelope for this endpoint,
	/// so this decodes as a bare array; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - limit: Maximum number of results to return.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	case all(limit: Int? = nil, offset: Int? = nil)

	public var path: String {
		switch self {
			case .create:
				return "/api/v1/request"
			case .get(let id), .delete(let id):
				return "/api/v1/request/\(id)"
			case .updateStatus:
				return "/api/v1/request/status"
			case .all:
				return "/api/v1/requests"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .create, .updateStatus:
				return [.post]
			case .get, .all:
				return [.get]
			case .delete:
				return [.delete]
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
			case .create(let id, let type):
				return AnyEncodable(CreateRequestRequest(id: id, type: type))
			case .updateStatus(let requestId, let status):
				return AnyEncodable(UpdateRequestStatusRequest(requestId: requestId, status: status))
			default:
				return nil
		}
	}
}

struct CreateRequestRequest: Encodable, Sendable {
	let id: String
	let type: RequestKind
}

struct UpdateRequestStatusRequest: Encodable, Sendable {
	let requestId: String
	let status: RequestStatus
}
