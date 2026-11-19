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

	/// Cancel a request that hasn't finished: waiting for a manager, queued, or in the download pipeline. Allowed for
	/// the user who made it and for users with `manageRequests`. Tracks the request already added to the requester's
	/// library are taken back out.
	///
	/// Returns ``CancelRequestResponse``: `.cancelled` at once for a waiting request, `.cancelling` for one in the
	/// pipeline (it reports ``RequestStatus/cancelled`` over ``NafynDownloadSocket`` shortly after). The server answers
	/// 409 when the request has already finished.
	/// - Parameter id: Request ID.
	case cancel(id: String)

	/// List download requests, paginated. Users with `manageRequests` get every request across every
	/// user; others get only their own.
	///
	/// Returns `[`` NafynRequest``]`. The spec doesn't detail a pagination envelope for this endpoint,
	/// so this decodes as a bare array; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - limit: Maximum number of results to return.
	///   - offset: Pagination offset. Defaults to `0` server-side when omitted.
	///   - succeeded: Include completed requests; `false` leaves them out. Defaults to `true` server-side.
	///   - failed: Include failed requests; `false` leaves them out. Defaults to `true` server-side.
	///   - waiting: Include requests waiting for a manager to accept them; `false` leaves them out. Defaults to `true` server-side.
	///   - processing: Include requests being worked on (searching, downloading, processing); `false` leaves them out. Defaults to `true` server-side.
	///   - type: Only album requests or only track requests; `nil` lists both.
	///   - user: Only the requests of this account (a user id, see ``requesters``). For a user without `manageRequests`
	///     any id but their own lists nothing.
	case all(limit: Int? = nil, offset: Int? = nil, succeeded: Bool? = nil, failed: Bool? = nil, waiting: Bool? = nil, processing: Bool? = nil, type: RequestKind? = nil, user: String? = nil)

	/// The accounts that made at least one listed request, sorted by name: the choices of ``all(limit:offset:succeeded:failed:waiting:processing:type:user:)``'s
	/// `user` filter. Requires `manageRequests` (403 otherwise).
	///
	/// Returns `[`` RequestRequester``]`.
	case requesters

	public var path: String {
		switch self {
			case .create:
				return "/api/v1/request"
			case .get(let id), .delete(let id):
				return "/api/v1/request/\(id)"
			case .cancel(let id):
				return "/api/v1/request/\(id)/cancel"
			case .updateStatus:
				return "/api/v1/request/status"
			case .all:
				return "/api/v1/requests"
			case .requesters:
				return "/api/v1/requests/requesters"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .create, .updateStatus, .cancel:
				return [.post]
			case .get, .all, .requesters:
				return [.get]
			case .delete:
				return [.delete]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .all(let limit, let offset, let succeeded, let failed, let waiting, let processing, let type, let user):
				var items: [URLQueryItem] = []
				if let limit {
					items.append(URLQueryItem(name: "limit", value: String(limit)))
				}
				if let offset {
					items.append(URLQueryItem(name: "offset", value: String(offset)))
				}
				if let succeeded {
					items.append(URLQueryItem(name: "succeeded", value: String(succeeded)))
				}
				if let failed {
					items.append(URLQueryItem(name: "failed", value: String(failed)))
				}
				if let waiting {
					items.append(URLQueryItem(name: "waiting", value: String(waiting)))
				}
				if let processing {
					items.append(URLQueryItem(name: "processing", value: String(processing)))
				}
				if let type {
					items.append(URLQueryItem(name: "type", value: type.rawValue))
				}
				if let user {
					items.append(URLQueryItem(name: "user", value: user))
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
