# ``Safyn``

A Swift client for the Nafyn API — self-hosted music library and Soulseek-download control, from iOS, macOS, tvOS, and visionOS apps.

## Overview

Safyn wraps every Nafyn endpoint in a small set of `enum`s, one per API category (``Album``, ``Artist``,
``Auth``, ``Library``, ``Playlist``, ``Request``, ``Search``, ``Settings``, ``Track``, ``User``,
``Users``), and executes them through a single ``NafynServer``. Because Nafyn is typically self-hosted,
you first validate a server's URL into a ``NafynInstance`` before you can talk to it:

```swift
import Safyn

let instance = try await NafynInstance.connect(appName: "MyApp", to: URL(string: "http://192.168.1.138:3000")!)
let server = NafynServer(instance: instance)

let auth: AuthResponse = try await server.send(Auth.login(username: "me", password: "hunter2"))
server.authToken = auth.token

let album: AlbumDetail = try await server.send(Album.get(aid: "b84ee12a-09ef-421b-82de-0441a926375b"))
```

Plain `http://` connections are only allowed to local/private hosts (loopback, RFC 1918 private
ranges, `.local` mDNS hosts); anything else must use `https://`.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:DebuggingRequests>
- <doc:HandlingErrors>
- ``NafynInstance``
- ``NafynServer``
- ``NafynEndpoint``
- ``NafynError``

### Guides

- <doc:ProfileAndPreferences>
- <doc:SessionsAndAccess>
- <doc:BrowsingTheLibrary>
- <doc:ManagingLibraryTracks>
- <doc:UploadingFiles>
- <doc:RemoteControlWithUnity>

### Endpoints

- ``Album``
- ``Artist``
- ``Auth``
- ``Library``
- ``Playlist``
- ``Request``
- ``Search``
- ``Settings``
- ``Track``
- ``User``
- ``Users``

### Live download progress

- ``NafynDownloadSocket``
- ``DownloadProgressEvent``

### Sessions

- ``SessionSummary``

### Nafyn Unity

- ``NafynUnitySocket``
- ``UnitySettings``
- ``UnityEvent``
- ``UnityPlaybackState``
- ``UnityCommand``
- ``UnityMasterStatus``
- ``JSONValue``
