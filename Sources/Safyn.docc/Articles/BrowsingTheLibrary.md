# Browsing the Library

List, page through, and look up the tracks and albums a user owns.

## Overview

``Library`` has two groups of endpoints. This article covers the *read* side: finding things. To play,
tag, or delete a track, see <doc:ManagingLibraryTracks>. Importing audio is in <doc:UploadingFiles>.

Two IDs appear throughout: a track's Nafyn **media ID** (``MediaRow/id``), and an album's
**MusicBrainz release-group ID** (``AlbumRow/mbId``). Check each parameter's documentation for which one
it expects.

## Your tracks and albums

``Library/tracks(limit:offset:)`` lists every track you own as ``MediaRow``s, and
``Library/albums(limit:offset:)`` lists the albums you own at least one track from as ``AlbumRow``s. Both
page with `limit` and `offset`:

```swift
let page1: [MediaRow] = try await server.send(Library.tracks(limit: 50, offset: 0))
let page2: [MediaRow] = try await server.send(Library.tracks(limit: 50, offset: 50))
```

Stop when a page comes back with fewer items than `limit`. See <doc:GettingStarted> for more on paging.

## One track or one album

Look up a single item for a detail screen:

```swift
let track: LibraryTrackResponse = try await server.send(Library.track(id: mediaId))
let album: LibraryAlbumResponse = try await server.send(Library.album(id: releaseGroupId))
```

Both responses add cover-derived colours (`imageColors`, `textColor`) for theming a screen.
``LibraryAlbumResponse`` contains only the tracks *you* own, not the full release.

## Recently played

``Library/recentlyPlayed`` returns a ``RecentlyPlayedEntry`` list, newest first. Each entry says what it
is (``RecentEntryKind``: track, album or playlist) and carries a title and cover ready to display.

Record a play with ``Library/recordRecentlyPlayed(type:refId:)``. `refId` is a media ID for a track, a
release-group ID for an album, or a playlist ID:

```swift
let recent: [RecentlyPlayedEntry] = try await server.send(Library.recentlyPlayed)
try await server.send(Library.recordRecentlyPlayed(type: .track, refId: mediaId)) as RecordedResponse
```

## Everyone's library (admins)

``Library/all(page:limit:)`` lists media across every user, including owner usernames. It requires the
`manageMusic` permission and is the one endpoint that uses `page`/`limit` and returns a
``PaginatedResponse``:

```swift
let result: PaginatedResponse<LibraryMediaEntry> = try await server.send(Library.all(page: 1, limit: 25))
if result.hasMore { /* request page 2 */ }
```

## See also

- <doc:ManagingLibraryTracks>
- <doc:HandlingErrors>, since a 403 here usually means a missing permission.
