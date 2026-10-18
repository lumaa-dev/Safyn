// Made by Lumaa

import Foundation

/// A playback snapshot published by the Unity master and relayed to every other device.
public struct UnityPlaybackState: Codable, Sendable, Hashable {
	/// The play queue. Holds full track objects, so a slave can render directly from it; decode
	/// entries with ``JSONValue/decode(_:)``.
	public var queue: [JSONValue]

	/// The index of the current track within ``queue``.
	public var currentIndex: Int

	public var isPlaying: Bool
	public var isLoading: Bool

	/// Playback position in seconds.
	public var currentTime: Double

	/// Current track duration in seconds.
	public var duration: Double

	public var volume: Double
	public var muted: Bool

	/// The repeat mode, as the master's player names it (e.g. `"off"`, `"all"`, `"one"`).
	public var repeatMode: String

	public init(queue: [JSONValue] = [], currentIndex: Int = 0, isPlaying: Bool = false, isLoading: Bool = false, currentTime: Double = 0, duration: Double = 0, volume: Double = 1, muted: Bool = false, repeatMode: String = "off") {
		self.queue = queue
		self.currentIndex = currentIndex
		self.isPlaying = isPlaying
		self.isLoading = isLoading
		self.currentTime = currentTime
		self.duration = duration
		self.volume = volume
		self.muted = muted
		self.repeatMode = repeatMode
	}

	private enum CodingKeys: String, CodingKey {
		case queue, currentIndex, isPlaying, isLoading, currentTime, duration, volume, muted
		case repeatMode = "repeat"
	}
}

/// Whether a Unity master currently exists.
public enum UnityMasterStatus: Sendable, Hashable {
	/// A master is connected and publishing state.
	case active
	/// No master; any device may claim.
	case empty
	/// Any other value the server sends.
	case other(String)
}

extension UnityMasterStatus: Codable {
	public init(from decoder: Decoder) throws {
		let raw = try decoder.singleValueContainer().decode(String.self)
		switch raw {
			case "active": self = .active
			case "empty": self = .empty
			default: self = .other(raw)
		}
	}

	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		switch self {
			case .active: try container.encode("active")
			case .empty: try container.encode("empty")
			case .other(let raw): try container.encode(raw)
		}
	}
}

/// A remote-control command a slave sends to the master. The master's player method name is the
/// wire `action`; the arguments are its `payload` array.
public enum UnityCommand: Sendable, Hashable {
	case play
	case togglePlay
	case stop
	case next
	case prev
	/// Seek to a position, in seconds.
	case seek(Double)
	/// Volume, `0...1`.
	case setVolume(Double)
	case toggleMute
	/// Add a track object to the queue.
	case addToQueue(JSONValue)
	case removeFromQueue(index: Int)
	case playFromQueue(index: Int)
	case cycleRepeat
	case setRepeat(String)
	/// Any action not modelled above.
	case custom(action: String, payload: [JSONValue])

	/// The wire `action` name.
	public var action: String {
		switch self {
			case .play: "play"
			case .togglePlay: "togglePlay"
			case .stop: "stop"
			case .next: "next"
			case .prev: "prev"
			case .seek: "seek"
			case .setVolume: "setVolume"
			case .toggleMute: "toggleMute"
			case .addToQueue: "addToQueue"
			case .removeFromQueue: "removeFromQueue"
			case .playFromQueue: "playFromQueue"
			case .cycleRepeat: "cycleRepeat"
			case .setRepeat: "setRepeat"
			case .custom(let action, _): action
		}
	}

	/// The wire `payload` argument array.
	public var payload: [JSONValue] {
		switch self {
			case .play, .togglePlay, .stop, .next, .prev, .toggleMute, .cycleRepeat: []
			case .seek(let value), .setVolume(let value): [.number(value)]
			case .addToQueue(let track): [track]
			case .removeFromQueue(let index), .playFromQueue(let index): [.number(Double(index))]
			case .setRepeat(let mode): [.string(mode)]
			case .custom(_, let payload): payload
		}
	}

	/// Builds a command from a received `action`/`payload` pair (what a master receives).
	/// Unrecognised or malformed pairs become ``custom(action:payload:)``.
	public init(action: String, payload: [JSONValue]) {
		func number(_ i: Int = 0) -> Double? {
			if payload.indices.contains(i), case .number(let n) = payload[i] { return n }
			return nil
		}
		switch (action, payload.first) {
			case ("play", _): self = .play
			case ("togglePlay", _): self = .togglePlay
			case ("stop", _): self = .stop
			case ("next", _): self = .next
			case ("prev", _): self = .prev
			case ("toggleMute", _): self = .toggleMute
			case ("cycleRepeat", _): self = .cycleRepeat
			case ("seek", _) where number() != nil: self = .seek(number()!)
			case ("setVolume", _) where number() != nil: self = .setVolume(number()!)
			case ("removeFromQueue", _) where number() != nil: self = .removeFromQueue(index: Int(number()!))
			case ("playFromQueue", _) where number() != nil: self = .playFromQueue(index: Int(number()!))
			case ("addToQueue", let track?): self = .addToQueue(track)
			case ("setRepeat", .string(let mode)?): self = .setRepeat(mode)
			default: self = .custom(action: action, payload: payload)
		}
	}
}

/// A message pushed by the server over `/ws/unity`.
public enum UnityEvent: Decodable, Sendable {
	/// Sent on connect. `role` is the server's name for this device's role.
	case snapshot(role: String, state: UnityPlaybackState?, masterDeviceLabel: String?, masterStatus: UnityMasterStatus)
	case claimGranted
	case claimRejected(reason: String?)
	/// Someone took or released master. `youAreMaster` tells whether it's this device.
	case masterChanged(youAreMaster: Bool, deviceLabel: String?)
	/// Playback snapshot from the master.
	case state(UnityPlaybackState)
	/// A slave's command, forwarded. Only the master receives these; it must execute them.
	case command(UnityCommand)
	/// The master dropped; it has `gracePeriodMs` (30s) to return.
	case masterDisconnected(gracePeriodMs: Int)
	/// The grace period expired; anyone can claim.
	case masterCleared
	case error(code: String, message: String)
	/// A message type this client doesn't know.
	case unknown(type: String)

	private enum CodingKeys: String, CodingKey {
		case type, role, state, masterDeviceLabel, masterStatus, reason, youAreMaster, deviceLabel
		case action, payload, gracePeriodMs, code, message
	}

	public init(from decoder: Decoder) throws {
		let c = try decoder.container(keyedBy: CodingKeys.self)
		let type = try c.decode(String.self, forKey: .type)
		switch type {
			case "snapshot":
				self = .snapshot(
					role: try c.decode(String.self, forKey: .role),
					state: try c.decodeIfPresent(UnityPlaybackState.self, forKey: .state),
					masterDeviceLabel: try c.decodeIfPresent(String.self, forKey: .masterDeviceLabel),
					masterStatus: try c.decode(UnityMasterStatus.self, forKey: .masterStatus)
				)
			case "claim-granted":
				self = .claimGranted
			case "claim-rejected":
				self = .claimRejected(reason: try c.decodeIfPresent(String.self, forKey: .reason))
			case "master-changed":
				self = .masterChanged(
					youAreMaster: try c.decode(Bool.self, forKey: .youAreMaster),
					deviceLabel: try c.decodeIfPresent(String.self, forKey: .deviceLabel)
				)
			case "state":
				self = .state(try c.decode(UnityPlaybackState.self, forKey: .state))
			case "command":
				let payload = try c.decodeIfPresent([JSONValue].self, forKey: .payload) ?? []
				self = .command(UnityCommand(action: try c.decode(String.self, forKey: .action), payload: payload))
			case "master-disconnected":
				self = .masterDisconnected(gracePeriodMs: try c.decode(Int.self, forKey: .gracePeriodMs))
			case "master-cleared":
				self = .masterCleared
			case "error":
				self = .error(code: try c.decode(String.self, forKey: .code), message: try c.decode(String.self, forKey: .message))
			default:
				self = .unknown(type: type)
		}
	}
}
