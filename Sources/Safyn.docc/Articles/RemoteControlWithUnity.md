# Remote Control with Nafyn Unity

Control playback on one of your devices from another, in real time.

## Overview

Nafyn Unity connects all of a user's devices over one WebSocket. At any moment at most one device is the
**master**: it plays the audio and publishes its playback state. Every other device is a **slave**: it
shows that state and sends commands, which the server forwards to the master.

``NafynUnitySocket`` is Safyn's client for it. Unlike the REST endpoints it is callback-based, because
it's a long-lived push connection.

## Connect

Check the user's preference first, because the server won't (see <doc:ProfileAndPreferences>). Then ask the
server for a socket. It needs an ``NafynServer/authToken``, otherwise it throws
``NafynError/unauthenticated``.

```swift
let settings: UnitySettings = try await server.send(User.unitySettings)
guard settings.enabled else { return }

let socket = try server.unitySocket()
socket.onEvent = { event in /* see below */ }
socket.onClose = { code, reason in /* see "Handle closing" */ }
socket.onError = { error in print(error) }
socket.connect()
```

Call ``NafynUnitySocket/disconnect()`` when you're done, for example when the app goes to the background.
The heartbeat (`ping`/`pong`) is answered for you.

## React to events

Everything the server sends arrives as a ``UnityEvent``. The first one after connecting is always
``UnityEvent/snapshot(role:state:masterDeviceLabel:masterStatus:)``:

```swift
socket.onEvent = { event in
    switch event {
    case .snapshot(_, let state, _, let status):
        switch status {
        case .active: if let state { render(state) }
        case .empty:  break // nobody is playing; you may claim master
        case .other:  break
        }
    case .state(let state):
        render(state)
    case .masterChanged(let youAreMaster, let label):
        updateBadge(isMe: youAreMaster, device: label)
    case .masterDisconnected(let graceMs):
        showReconnecting(timeoutMs: graceMs)   // master has ~30 s to come back
    case .masterCleared:
        break                                  // anyone can claim now
    case .error(let code, let message):
        print(code, message)                   // e.g. "no-master"
    default:
        break
    }
}
```

Unknown message types are delivered as ``UnityEvent/unknown(type:)`` rather than failing, so new server
features won't break your app.

## Act as a slave (remote)

Send a ``UnityCommand`` with ``NafynUnitySocket/send(_:)``. The server forwards it to the master:

```swift
socket.send(.togglePlay)
socket.send(.seek(93))        // seconds
socket.send(.setVolume(0.5))  // 0...1
socket.send(.playFromQueue(index: 2))
```

If there is no master you receive an ``UnityEvent/error(code:message:)`` with code `no-master`. Render
the UI from ``UnityPlaybackState``, whose `queue` already contains full track objects. Each entry is a
``JSONValue``; decode it with ``JSONValue/decode(_:)`` into your own type.

## Become the master

Only do this if your app plays audio itself — **the server plays nothing**.

- ``NafynUnitySocket/claimMaster()`` works when no master is active. You receive
  ``UnityEvent/claimGranted`` or ``UnityEvent/claimRejected(reason:)``.
- ``NafynUnitySocket/takeover()`` takes control at any time.

A master has two jobs:

1. **Publish state** with ``NafynUnitySocket/sendState(_:)`` after every change and roughly once a second.
2. **Execute commands** that arrive as ``UnityEvent/command(_:)``.

```swift
case .command(let command):
    switch command {
    case .togglePlay:        player.togglePlay()
    case .seek(let seconds): player.seek(to: seconds)
    case .custom(let action, _): print("unsupported:", action)
    default: break
    }
```

If the master's socket drops, the server keeps the role for 30 seconds
(``UnityEvent/masterDisconnected(gracePeriodMs:)``) before sending ``UnityEvent/masterCleared``.

## Handle closing

``NafynUnitySocket/onClose`` receives a close code:

| Code | Meaning | What to do |
| --- | --- | --- |
| `4000` | Missing token | Fix the code path that built the socket |
| `4001` | Token invalid, expired or revoked | Sign the user in again |
| `4002` | Unity is disabled on the server | Hide Unity UI; don't retry |
| `4003` | This session was revoked | Treat as signed out |
| `4008` | Heartbeat timeout | Safe to reconnect |

## See also

- ``UnityPlaybackState``, ``UnityCommand``, ``UnityMasterStatus``
- <doc:SessionsAndAccess>, since revoking a session closes its socket with `4003`.
