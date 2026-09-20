// Made by Lumaa

import Foundation

/// A single part of a `multipart/form-data` request.
///
/// Used by ``NafynEndpoint/multipart`` for the endpoints that accept file uploads (playlist/track
/// covers, user avatars, track import) or mix file and text fields in one request (e.g.
/// `Library.importTrack`). Mutually exclusive with ``NafynEndpoint/body``.
public enum MultipartPart: Sendable, Equatable {
	/// A file field, e.g. an image or audio upload.
	case file(fieldName: String, filename: String, mimeType: String, data: Data)

	/// A plain text field, sent alongside file parts in the same request.
	case text(fieldName: String, value: String)
}
