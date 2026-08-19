// Made by Lumaa

import Foundation

/// A single file to upload as `multipart/form-data`.
///
/// Used by ``NafynEndpoint/multipart`` for the endpoints that accept file uploads
/// (playlist covers, user avatars). Mutually exclusive with ``NafynEndpoint/body``.
public struct MultipartFile: Sendable, Equatable {
	/// The form field name the server expects the file under, e.g. `"image"` or `"avatar"`.
	public let fieldName: String

	/// The filename reported in the `Content-Disposition` header, e.g. `"upload.webp"`.
	public let filename: String

	/// The MIME type of `data`, e.g. `"image/webp"`.
	public let mimeType: String

	/// The raw file bytes.
	public let data: Data

	public init(fieldName: String, filename: String, mimeType: String, data: Data) {
		self.fieldName = fieldName
		self.filename = filename
		self.mimeType = mimeType
		self.data = data
	}
}
