# Playing and Managing Library Tracks

Stream audio, show lyrics and covers, edit metadata, and remove tracks.

## Overview

These ``Library`` endpoints act on one track at a time and take its Nafyn media ID (``MediaRow/id``).
To find tracks first, see <doc:BrowsingTheLibrary>.

## Stream audio

``Library/stream(id:token:range:)`` returns the audio file as raw `Data`, so use
``NafynServer/sendRaw(_:)``. It supports HTTP byte ranges, so you can fetch part of a file:

```swift
let firstKB: Data = try await server.sendRaw(Library.stream(id: mediaId, range: "bytes=0-1023"))
```

For real playback, don't download through Safyn: give the stream URL to `AVPlayer`. Players can't set an
`Authorization` header on every request, so the `token:` parameter exists to pass your auth token as a
query item instead. The same fallback exists on ``Library/cover(id:token:)``.

## Lyrics

``Library/lyrics(id:)`` returns time-synced ``Lyrics`` (paragraphs → lines → segments) from the first
provider that has a match. Highlight lines by comparing `startTime`/`endTime` to the player's time.

You can also store your own lyrics for a track, as plain text or synced LRC:

```swift
try await server.sendRaw(Library.setLyrics(id: mediaId, content: lrcText, format: .lrc))
try await server.sendRaw(Library.deleteLyrics(id: mediaId))
```

## Covers

- ``Library/cover(id:token:)`` fetches the uploaded cover (`image/webp`) as raw `Data`.
- ``Library/setCover(id:data:filename:mimeType:)`` uploads PNG, JPEG or WebP. See <doc:UploadingFiles>.
- ``Library/deleteCover(id:)`` removes it.

`setCover` and `deleteCover` return the updated ``MediaRow``.

## Edit metadata

``Library/editMetadata(id:title:artistName:album:albumType:releaseDate:duration:label:trackNumber:coverArt:)``
changes only the fields you pass and returns the updated ``MediaRow``. Fields that can be cleared use
``Patchable`` (`.unset` leaves it, `.value(_:)` sets it, `.clear` removes it), exactly as in
<doc:ProfileAndPreferences>:

```swift
let updated: MediaRow = try await server.send(
    Library.editMetadata(id: mediaId, title: "Corrected Title", label: .clear, trackNumber: .value(3))
)
```

## Remove a track

``Library/remove(id:)`` removes a track from *your* library. If no other user still has it, the file is
deleted from the server too. The ``RemovedWithFileResponse`` tells you whether that happened:

```swift
let result: RemovedWithFileResponse = try await server.send(Library.remove(id: mediaId))
print(result.fileDeleted)
```

``Library/removeForUser(id:userId:)`` removes it from another user's library. It's allowed for that user
or anyone with `manageMusic`; otherwise the server returns an error (see <doc:HandlingErrors>).

## See also

- <doc:BrowsingTheLibrary>
- <doc:UploadingFiles>
