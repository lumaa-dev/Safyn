// Made by Lumaa

import Foundation

/// A live client for Nafyn Unity (`/ws/unity`): one device is the *master* and plays audio, every other
/// device is a *slave* that renders the master's state and sends it commands.
///
/// Create one via ``NafynServer/unitySocket()``:
/// ```swift
/// let socket = try server.unitySocket()
/// socket.onEvent = { event in
///     switch event {
///         case .snapshot(_, let state, _, let status):
///             if status == .empty { socket.claimMaster() }
///         case .state(let state): break // render
///         default: break
///     }
/// }
/// socket.connect()
/// socket.send(.seek(93))
/// ```
///
/// Heartbeat is handled for you: the server's `ping` is answered with `pong`.
///
/// A third-party master must play audio itself, call ``sendState(_:)`` after each change and about once
/// per second, and execute incoming ``UnityEvent/command(_:)`` events. The server does none of that.
///
/// - Note: Like ``NafynDownloadSocket``, this is `@unchecked Sendable` with callback closures, since
///   `URLSessionWebSocketTask` delegate callbacks fire on an arbitrary queue.
public final class NafynUnitySocket: NSObject, @unchecked Sendable {
	private let request: URLRequest
	private var session: URLSession!
	private var task: URLSessionWebSocketTask?

	/// Called for every message the server pushes.
	public var onEvent: (@Sendable (UnityEvent) -> Void)?

	/// Called when the connection closes, with the close code and optional reason.
	///
	/// Nafyn closes with `4000` (missing token), `4001` (invalid, expired or revoked token), `4002`
	/// (Unity disabled on the server), `4003` (this session was revoked) or `4008` (heartbeat timeout).
	public var onClose: (@Sendable (Int, String?) -> Void)?

	/// Called for transport errors, including failures to decode a pushed message.
	public var onError: (@Sendable (any Error) -> Void)?

	init(request: URLRequest) {
		self.request = request
		super.init()
		self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
	}

	/// Opens the connection and starts listening.
	public func connect() {
		let task = session.webSocketTask(with: request)
		self.task = task
		task.resume()
		listen()
	}

	/// Closes the connection.
	public func disconnect() {
		task?.cancel(with: .normalClosure, reason: nil)
		task = nil
	}

	// MARK: - Sending

	/// Becomes master. Valid when no master is active; answered by ``UnityEvent/claimGranted`` or ``UnityEvent/claimRejected(reason:)``.
	public func claimMaster() {
		write(["type": .string("claim-master")])
	}

	/// Takes master from the current one, at any time.
	public func takeover() {
		write(["type": .string("takeover")])
	}

	/// Sends a remote-control command to the master (slaves only). The server answers with an
	/// ``UnityEvent/error(code:message:)`` of `no-master` if there is none.
	public func send(_ command: UnityCommand) {
		write([
			"type": .string("command"),
			"action": .string(command.action),
			"payload": .array(command.payload),
		])
	}

	/// Publishes playback state (master only): after each change, and about once per second.
	public func sendState(_ state: UnityPlaybackState) {
		guard let data = try? JSONEncoder().encode(state),
		      let value = try? JSONDecoder().decode(JSONValue.self, from: data)
		else { return }
		write(["type": .string("state"), "state": value])
	}

	private func write(_ message: [String: JSONValue]) {
		guard let data = try? JSONEncoder().encode(message),
		      let text = String(data: data, encoding: .utf8)
		else { return }
		task?.send(.string(text)) { [weak self] error in
			if let error { self?.onError?(error) }
		}
	}

	// MARK: - Receiving

	private func listen() {
		task?.receive { [weak self] result in
			guard let self else { return }
			switch result {
				case .success(let message):
					switch message {
						case .string(let text): self.handle(Data(text.utf8))
						case .data(let data): self.handle(data)
						@unknown default: break
					}
					self.listen()
				case .failure(let error):
					// close codes surface via the delegate below
					self.onError?(error)
			}
		}
	}

	private func handle(_ data: Data) {
		// heartbeat: `{"type":"ping"}` (or a bare "ping") → pong
		if data == Data("ping".utf8) || (try? JSONDecoder().decode(Heartbeat.self, from: data))?.type == "ping" {
			write(["type": .string("pong")])
			return
		}
		do {
			onEvent?(try JSONDecoder().decode(UnityEvent.self, from: data))
		} catch {
			onError?(error)
		}
	}

	private struct Heartbeat: Decodable {
		let type: String
	}
}

extension NafynUnitySocket: URLSessionWebSocketDelegate {
	public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) }
		onClose?(closeCode.rawValue, reasonString)
	}
}
