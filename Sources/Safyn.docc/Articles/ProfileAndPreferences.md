# Profile and Preferences

Read and edit the signed-in user's profile, avatar, and personal settings.

## Overview

Everything here acts on the user whose ``NafynServer/authToken`` is set, so none of these calls take a
user ID (except fetching someone's avatar). Admin actions on *other* accounts live in ``Users``.

## Read your profile

``User/me`` returns a ``NafynUser``:

```swift
let me: NafynUser = try await server.send(User.me)
print(me.displayName ?? me.username)

if me.permissions.has(.manageMusic) { /* show library admin UI */ }
```

Use ``Permissions/has(_:)`` rather than `contains(_:)`: `admin` implicitly grants everything.

## Update your profile

``User/updateProfile(displayName:listenBrainz:discogs:)`` only changes what you pass. `displayName` is a plain
optional (omit it to leave it alone). `listenBrainz` and `discogs` are *clearable*, so they use ``Patchable``,
which has three states:

| Value | Effect |
| --- | --- |
| `.unset` (default) | Field isn't sent; nothing changes |
| `.value("name")` | Sets the field |
| `.clear` | Sends `null`; unlinks the field |

```swift
let updated: NafynUser = try await server.send(
    User.updateProfile(displayName: "Alex", listenBrainz: .value("alex-lb"), discogs: .clear)
)
```

## Avatars

Fetch any user's avatar with ``User/avatar(id:token:)``. It returns an `image/webp` body, so use
``NafynServer/sendRaw(_:)``:

```swift
let webp: Data = try await server.sendRaw(User.avatar(id: me.id))
```

Upload your own with ``User/setAvatar(data:filename:mimeType:)`` (see <doc:UploadingFiles> for how
uploads work), and remove it with ``User/deleteAvatar``. Both return the updated ``NafynUser``:

```swift
let withAvatar: NafynUser = try await server.send(User.setAvatar(data: webpData))
let without: NafynUser = try await server.send(User.deleteAvatar)
```

## Display preferences

``User/appearanceSettings`` and ``User/updateAppearanceSettings(showFileSize:showDuration:)`` control what
track lists show. Both return ``AppearanceSettings``:

```swift
let settings: AppearanceSettings = try await server.send(
    User.updateAppearanceSettings(showDuration: true)
)
```

> Note: Turning `showFileSize` on requires the `manageMusic` or `admin` permission. Without it the server
> silently ignores the change instead of returning an error, so re-read the returned value.

## Nafyn Unity preference

``User/unitySettings`` and ``User/updateUnitySettings(enabled:)`` read and set whether Nafyn Unity
(remote playback control) is on for the account. Both return ``UnitySettings``.

> Important: The server does **not** check this setting when a Unity socket connects. Your app must read
> it and decide whether to connect. See <doc:RemoteControlWithUnity>.

## See also

- <doc:SessionsAndAccess> for signing out devices and managing API tokens.
