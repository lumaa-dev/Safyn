# Safyn

A Swift client for the [Nafyn API](https://github.com/lumaa-dev/nafyn) — self-hosted music library and Soulseek-download control, for iOS, macOS, tvOS, and visionOS.

> [Documentation](https://lumaa-dev.github.io/Safyn/documentation/safyn/)

## Installation

Add Safyn as a dependency in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/lumaa-dev/Safyn", from: "1.0.0"),
],
```

Or in Xcode: **File → Add Package Dependencies…** and paste the repository URL.

## Quick start

```swift
import Safyn

// Nafyn is self-hosted, so validate the server's URL before doing anything else.
let instance = try await NafynInstance.connect(to: URL(string: "http://192.168.1.138:3000")!)
let server = NafynServer(instance: instance)

// Log in and store the session token.
let auth: AuthResponse = try await server.send(Auth.login(username: "me", password: "hunter2"))
server.authToken = auth.token

// Call any endpoint by sending its case.
let album: AlbumDetail = try await server.send(Album.get(aid: "b84ee12a-09ef-421b-82de-0441a926375b"))
```

Every endpoint is grouped into an `enum` matching its Nafyn API category: ``Album``, ``Auth``, ``Library``, ``Playlist``, ``Request``, ``Search``, ``Settings``, ``Track``, ``User``, ``Users``.

Plain `http://` connections are only allowed to local/private hosts (`localhost`, loopback addresses, RFC 1918 private ranges, `.local` hosts) — anything else needs `https://`.

## Debugging

```swift
server.debugLoggingEnabled = true          // logs every request/response via os.Logger
```

See the [Debugging Requests](https://lumaa-dev.github.io/Safyn/documentation/safyn/debuggingrequests) article for more.

## Testing

`Tests/SafynTests` contains real integration tests (no mocking) against `http://localhost:3000/`
(see `TestSupport.swift`). They'll fail until you point that URL at a running Nafyn server — run them
from Xcode once you have one.

## Live download progress

Use ``NafynServer/downloadSocket(requestId:)`` to open a WebSocket to `/ws/downloads` and stream
``DownloadProgressEvent``s for a request in progress:

```swift
let socket = try server.downloadSocket(requestId: request.id)
socket.onEvent = { event in
    // update UI: event.stage, event.bytesDownloaded, event.totalBytes, ...
}
socket.connect()
// ...
socket.disconnect()
```

## Known limitations

- `StorageInfo.UserUsage`'s fields beyond `userId` are inferred, not spec-confirmed by the OpenAPI schema.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
