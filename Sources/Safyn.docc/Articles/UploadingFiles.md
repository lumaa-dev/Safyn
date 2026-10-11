# Uploading Files

How Safyn sends images and audio to the server, and how to add your own upload endpoint.

## Overview

Most requests send JSON. Endpoints that take files send `multipart/form-data` instead. In Safyn that is
the three avatar and cover uploads plus track import:

| Endpoint | What you upload |
| --- | --- |
| ``User/setAvatar(data:filename:mimeType:)`` | Your avatar |
| ``Users/setAvatar(id:data:filename:mimeType:)`` | Another user's avatar (admin) |
| ``Playlist/setImage(pid:data:filename:mimeType:)`` | A playlist image |
| ``Library/setCover(id:data:filename:mimeType:)`` | A track cover |
| ``Library/importTrack(audio:audioFilename:audioMimeType:cover:coverFilename:coverMimeType:metadata:)`` | An audio file, optionally with cover and metadata |

You never build the multipart body yourself. Pass the raw bytes and Safyn handles boundaries and headers.

## Upload an image

Pass the file's bytes. `filename` and `mimeType` have sensible defaults for the endpoint, so override
them only when your data is a different format:

```swift
let png = try Data(contentsOf: coverURL)
let row: MediaRow = try await server.send(
    Library.setCover(id: mediaId, data: png, filename: "cover.png", mimeType: "image/png")
)
```

> Tip: Make sure `mimeType` matches the bytes. The server decides based on what you declare.

## Import a track

``Library/importTrack(audio:audioFilename:audioMimeType:cover:coverFilename:coverMimeType:metadata:)``
mixes files and text in one request. `metadata` is a *JSON string* with any of `title`, `artist`,
`album`, `albumType`, `duration`, `trackNumber`, `releaseDate`, `label` and `lyrics`:

```swift
let audio = try Data(contentsOf: fileURL)
let metadata = #"{"title":"Song","artist":"Band","album":"Record","trackNumber":1}"#

let imported: MediaRow = try await server.send(
    Library.importTrack(
        audio: audio, audioFilename: "song.flac", audioMimeType: "audio/flac",
        metadata: metadata
    )
)
```

Everything is held in memory while uploading, so for very large files consider the app's memory limits.

## How it works (for endpoint authors)

An endpoint opts into multipart by returning ``MultipartPart`` values from ``NafynEndpoint/multipart``.
There are two kinds:

- ``MultipartPart/file(fieldName:filename:mimeType:data:)`` — a file field
- ``MultipartPart/text(fieldName:value:)`` — a plain text field

```swift
public var multipart: [MultipartPart]? {
    switch self {
    case .setCover(_, let data, let filename, let mimeType):
        return [.file(fieldName: "cover", filename: filename, mimeType: mimeType, data: data)]
    default:
        return nil
    }
}
```

`fieldName` must be the name the Nafyn API expects (check the OpenAPI spec). An endpoint must return
*either* `multipart` *or* ``NafynEndpoint/body``, never both. When `multipart` is non-nil, ``NafynServer``
generates the boundary and sets the `Content-Type` header for you.

## See also

- <doc:ProfileAndPreferences>
- <doc:ManagingLibraryTracks>
