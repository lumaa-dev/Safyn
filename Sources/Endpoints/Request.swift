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

	/// List every download request across every user. Requires `manageRequests`.
	///
	/// Returns `[`` NafynRequest``]`.
	case all

	public var path: String {
		switch self {
			case .create:
				return "/api/v1/request"
			case .get(let id):
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
