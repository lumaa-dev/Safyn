# Debugging Requests

Diagnose a failing request without attaching a debugger.

## Read the error

Every throwing call in Safyn throws a ``NafynError``. Its `errorDescription` always surfaces the most
useful information available — for server-side failures, that includes the HTTP status code and the
message the Nafyn server sent back:

```swift
do {
    let album: AlbumDetail = try await server.send(Album.get(aid: badId))
} catch let error as NafynError {
    print(error.errorDescription ?? "Unknown error")
    // "Nafyn server error (404): No album/release found for that ID"
}
```

``NafynError/server(statusCode:error:)`` carries the full ``NuxtError`` payload if you need more than
the message, e.g. `statusCode` or the raw `stack`.

## Turn on request logging

Set ``NafynServer/debugLoggingEnabled`` to log every request and response through `os.Logger`
(subsystem `"com.safyn"`, category `"network"`) — visible in Console.app or Xcode's console while
debugging:

```swift
server.debugLoggingEnabled = true
```

## Reproduce a request outside your app

``NafynServer/curlCommand(for:)`` builds an equivalent `curl` command for any endpoint, using the
exact same request-building logic as ``NafynServer/send(_:)`` — useful for confirming whether a bug is
in your app or on the server, or for sharing a repro case with whoever runs the Nafyn server:

```swift
print(server.curlCommand(for: Album.get(aid: someId)))
// curl -X GET -H 'Authorization: Bearer ...' 'http://192.168.1.138:3000/api/v1/album/...'
```
