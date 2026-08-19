// Made by Lumaa

import Foundation

/// A live client for Nafyn's `/ws/downloads` WebSocket, which streams ``DownloadProgressEvent``s for a single download request.
///
/// Create one via ``NafynServer/downloadSocket(requestId:)`` rather than the initializer directly, so
/// it picks up the instance's host/scheme and the server's current `authToken` automatically:
/// ```swift
/// let socket = try server.downloadSocket(requestId: request.id)
/// socket.onEvent = { event in
///     // update UI: event.stage, event.bytesDownloaded, event.totalBytes, ...
/// }
/// socket.onClose = { code, reason in
///     // 4000 missing token/requestId, 4001 invalid/expired token, 4004 request not found/not yours
/// }
/// socket.connect()
/// // ...
/// socket.disconnect() // e.g. on view disappear / scenePhase change
/// ```
///
/// - Note: `URLSessionWebSocketTask`'s delegate callbacks can fire on an arbitrary queue, so this
///   class is `@unchecked Sendable` rather than actor-isolated — that keeps its callback-based API
///   (``onEvent``, ``onClose``, ``onError``) simple to assign from any context, including a SwiftUI
///   view model, without every access needing `await`.
public final class NafynDownloadSocket: NSObject, @unchecked Sendable {
	private let url: URL
	private var session: URLSession!
	private var task: URLSessionWebSocketTask?
	private var pingTimer: Timer?

	/// Called for every progress update the server pushes.
	public var onEvent: (@Sendable (DownloadProgressEvent) -> Void)?

	/// Called when the connection closes, with the WebSocket close code and an optional reason.
	///
	/// Nafyn closes with `4000` (missing token/requestId), `4001` (invalid/expired token), or `4004`
	/// (request not found or not yours) for connection-time failures.
	public var onClose: (@Sendable (Int, String?) -> Void)?

	/// Called for transport errors, including failures to decode a pushed event.
	public var onError: (@Sendable (any Error) -> Void)?

	init(url: URL) {
		self.url = url
		super.init()
		self.session = URLSession(configuration: .default, delegate: self, delegateQueue: nil)
	}

	/// Opens the connection and starts listening for events.
	public func connect() {
		let task = session.webSocketTask(with: url)
		self.task = task
		task.resume()
		listen()
		startPing()
	}

	/// Closes the connection.
	public func disconnect() {
		pingTimer?.invalidate()
		pingTimer = nil
		task?.cancel(with: .normalClosure, reason: nil)
		task = nil
	}

	private func listen() {
		task?.receive { [weak self] result in
			guard let self else { return }
			switch result {
				case .success(let message):
					switch message {
						case .string(let text):
							self.handle(text)
						case .data(let data):
							self.handle(data)
						@unknown default:
							break
					}
					self.listen() // one receive call per message; re-arm after each
				case .failure(let error):
					self.onError?(error)
					// server closes with codes 4000/4001/4004 for bad token/request — surfaced via the delegate below
			}
		}
	}

	private func handle(_ text: String) {
		guard let data = text.data(using: .utf8) else { return }
		handle(data)
	}

	private func handle(_ data: Data) {
		do {
			let event = try JSONDecoder().decode(DownloadProgressEvent.self, from: data)
			onEvent?(event)
		} catch {
			onError?(error)
		}
	}

	// server sends no heartbeat of its own; ping to keep idle connections alive
	private func startPing() {
		pingTimer = Timer.scheduledTimer(withTimeInterval: 25, repeats: true) { [weak self] _ in
			guard let self else { return }
			self.task?.sendPing { [weak self] error in
				if let error {
					self?.onError?(error)
				}
			}
		}
	}
}

extension NafynDownloadSocket: URLSessionWebSocketDelegate {
	public func urlSession(_ session: URLSession, webSocketTask: URLSessionWebSocketTask, didCloseWith closeCode: URLSessionWebSocketTask.CloseCode, reason: Data?) {
		let reasonString = reason.flatMap { String(data: $0, encoding: .utf8) }
		onClose?(closeCode.rawValue, reasonString)
	}
}
