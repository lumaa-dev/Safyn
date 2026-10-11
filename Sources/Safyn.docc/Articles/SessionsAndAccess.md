# Sessions and API Tokens

See where you're signed in, sign devices out, and manage app passwords.

## Overview

Nafyn has two kinds of credentials for a user:

- **Sessions** — one per login. Each device that logs in gets its own session, and your `authToken` *is*
  that session.
- **API tokens** — long-lived app passwords, currently used for Subsonic-compatible clients.

## Sign out this device

``Auth/logout`` revokes the session that makes the request. The response has no body, so use
``NafynServer/sendRaw(_:)``, then forget the token locally:

```swift
try await server.sendRaw(Auth.logout)
server.authToken = nil
```

The token is rejected on its next request, and any open Unity socket for it closes with code `4003`.

## List your sessions

``User/sessions`` returns one ``SessionSummary`` per device:

```swift
let sessions: [SessionSummary] = try await server.send(User.sessions)
for session in sessions {
    print(session.deviceLabel, session.isCurrent ? "(this device)" : "")
}
```

`deviceLabel` is built by the server from the `User-Agent`, which is the `appName` you passed to
``NafynInstance/connect(appName:to:session:)``. Pick a recognisable name and users will see it here.

> Note: `lastSeenAt` is not updated by the server yet and currently equals `createdAt`. Don't present it
> as "last active".

## Sign out another device

``User/deleteSession(id:)`` revokes any of your sessions by ``SessionSummary/id``. It returns no body, and
fails with a 404 (``NafynError/server(statusCode:error:)``) if the ID isn't yours:

```swift
if let other = sessions.first(where: { !$0.isCurrent }) {
    try await server.sendRaw(User.deleteSession(id: other.id))
}
```

The revoked device may keep working for up to about 30 seconds because the server caches revocation. To
sign out the current device, use ``Auth/logout`` instead.

> Important: Tokens issued before sessions were introduced fail verification. After a server upgrade, users
> must log in again once.

## API tokens

``User/apiTokens`` lists your tokens as ``ApiTokenSummary`` values (never including the secret).
``User/createApiToken(name:)`` creates one and returns a ``CreateApiTokenResponse``:

```swift
let created: CreateApiTokenResponse = try await server.send(User.createApiToken(name: "Living room"))
show(created.token) // the only time the plaintext value is available
```

> Important: The plaintext `token` is returned **only** by this call. Show or store it immediately; it
> can't be retrieved again.

Revoke a token with ``User/deleteApiToken(id:)``, which returns no body:

```swift
try await server.sendRaw(User.deleteApiToken(id: created.id))
```

## See also

- <doc:ProfileAndPreferences>
- <doc:HandlingErrors> for what a failed revocation looks like.
