# Getting Started

Connect to a Nafyn server, authenticate, and make your first call.

## Add Safyn to your project

Add Safyn as a Swift Package dependency, then `import Safyn` wherever you need it.

## Connect to a server

Every Nafyn server is self-hosted, so before you can call any endpoint you need to validate its URL
into a ``NafynInstance``. This pings the server's `/api/_nafyn` health check and confirms it's really
running Nafyn:

```swift
let instance = try await NafynInstance.connect(appName: "MyApp", to: URL(string: "http://192.168.1.138:3000")!)
```

### Name your app

`appName` is mandatory. It becomes the `User-Agent` header of every request made through the instance
(including the connection check and the WebSocket handshakes), and the server uses it to label this
device in the user's sessions (see ``SessionSummary/deviceLabel``). It's set once here and can never be
changed for the lifetime of the instance and any ``NafynServer`` built from it; pass a different name by
connecting again. An empty name throws ``NafynError/invalidAppName``.

`connect(appName:to:session:)` only allows plain `http://` for local/private hosts (`localhost`, loopback
addresses, RFC 1918 private ranges, and `.local` hosts). Anything else — a public domain or IP — must
use `https://`, or this throws ``NafynError/insecureConnection(host:)``.

## Create a server

Wrap the instance in a ``NafynServer``, which is what actually executes endpoints:

```swift
let server = NafynServer(instance: instance)
```

## Log in

Most endpoints require authentication. Send an ``Auth`` case, then store the returned token on the
server:

```swift
let auth: AuthResponse = try await server.send(Auth.login(username: "me", password: "hunter2"))
server.authToken = auth.token
```

If you've already persisted a token from a previous session, skip logging in and pass it directly to
``NafynServer/init(instance:authToken:session:debugLoggingEnabled:)``.

## Call an endpoint

Every endpoint is a case on its category's `enum`. Pass one to ``NafynServer/send(_:)`` and specify
the expected response type:

```swift
let album: AlbumDetail = try await server.send(Album.get(aid: "b84ee12a-09ef-421b-82de-0441a926375b"))
```

For endpoints that return binary data (audio streams, cover art, avatars) use
``NafynServer/sendRaw(_:)`` instead, which returns `Data`:

```swift
let audio: Data = try await server.sendRaw(Library.stream(id: someTrackId))
```

## Page through a list endpoint

List endpoints take optional pagination parameters. Most (``Library/tracks(limit:offset:)``,
``Library/albums(limit:offset:)``, ``Playlist/list(limit:offset:)``, ``Playlist/tracks(pid:limit:offset:)``,
``Request/all(limit:offset:)``, ``Users/all(limit:offset:)``) use `limit`/`offset`:

```swift
let firstPage: [MediaRow] = try await server.send(Library.tracks(limit: 20, offset: 0))
let secondPage: [MediaRow] = try await server.send(Library.tracks(limit: 20, offset: 20))
```

``Library/all(page:limit:)`` is the one endpoint whose spec documents a full pagination envelope, so it
takes `page`/`limit` instead and returns a ``PaginatedResponse`` with `items`, `page`, `limit`, `total`,
and `hasMore`:

```swift
let entries: PaginatedResponse<LibraryMediaEntry> = try await server.send(Library.all(page: 1, limit: 20))
if entries.hasMore {
    let next: PaginatedResponse<LibraryMediaEntry> = try await server.send(Library.all(page: 2, limit: 20))
}
```
