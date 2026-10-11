# Handling Errors

Understand what ``NafynError`` tells you and how to react to each case.

## Overview

``NafynInstance`` and ``NafynServer`` throw a single error type, ``NafynError``. It conforms to
`LocalizedError`, so `error.localizedDescription` is always safe to show or log:

```swift
do {
    let me: NafynUser = try await server.send(User.me)
} catch let error as NafynError {
    print(error.localizedDescription)
} catch {
    // anything else, e.g. cancellation
}
```

Calls can also throw `CancellationError` when the surrounding `Task` is cancelled, so keep a general
`catch`.

## The cases

| Case | When it happens | Usual reaction |
| --- | --- | --- |
| ``NafynError/invalidAppName`` | `appName` was empty | Fix your code; it's a programmer error |
| ``NafynError/invalidURL`` | A URL couldn't be built | Check the server address you were given |
| ``NafynError/insecureConnection(host:)`` | `http://` to a non-local host | Ask for an `https://` address |
| ``NafynError/notNafynServer(url:)`` | Server answered but isn't Nafyn | Tell the user the address is wrong |
| ``NafynError/transport(_:)`` | No network, timeout, DNS, refused | Offer retry; check connectivity |
| ``NafynError/unauthenticated`` | Socket requested without `authToken` | Send the user to sign in |
| ``NafynError/server(statusCode:error:)`` | Server replied with non-2xx | Branch on `statusCode` (below) |
| ``NafynError/decoding(_:)`` | Response didn't match the model | Likely a version mismatch; see below |
| ``NafynError/invalidResponse`` | Non-HTTP or empty/unparseable error | Treat like a server failure |

### Connection errors

`insecureConnection` and `notNafynServer` come from ``NafynInstance/connect(appName:to:session:)``, so you
only see them while the user is entering a server address. They make good inline form errors.

### Server errors

``NafynError/server(statusCode:error:)`` carries the HTTP status and the server's ``NuxtError`` payload
(`message`, `statusMessage`, `url`, and sometimes `stack`). Branch on the status code:

```swift
catch let NafynError.server(statusCode, payload) {
    switch statusCode {
    case 400: showValidation(payload.message)
    case 401: signOut()                       // token missing, expired or revoked
    case 403: showNoPermission()              // e.g. needs manageMusic
    case 404: showNotFound()
    default:  showGeneric(payload.message ?? payload.statusMessage)
    }
}
```

A `401` on a call that used to work usually means the session was revoked (see
<doc:SessionsAndAccess>), so treat it as "sign in again".

### Decoding errors

``NafynError/decoding(_:)`` means the server answered successfully but Safyn couldn't read the body. Two
common causes:

- You asked for the wrong type. Endpoints with an empty response (for example ``Auth/logout`` and
  ``User/deleteSession(id:)``) must use ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
- The server is a different version than this package expects.

The associated string describes the underlying `DecodingError`, so include it in bug reports.

## Debugging

For logging requests and reproducing them outside your app, see <doc:DebuggingRequests>.

## See also

- <doc:GettingStarted>
