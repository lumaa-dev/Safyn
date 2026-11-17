// Made by Lumaa

import Foundation

/// The lyrics of a library track, returned by `Library.lyrics(id:)`.
///
/// The server parses every provider's format with Braccato (`@braccato/parsers`) and sends its `Lyric[]` shape
/// (`@braccato/types`) as ``lyrics``: one ``Line`` per lyric line, in order, with the syllable/word timing in
/// ``Line/parts`` when there is some. Times are milliseconds from the start of the track; ``Line/startTime`` and
/// friends give them in seconds. Shift every time by ``offset`` before matching it against the playback position.
public struct Lyrics: Codable, Sendable, Hashable {
	/// How the lyrics are timed.
	public enum SyncType: String, Codable, Sendable, Hashable {
		/// Lines carry timed ``Line/parts`` (syllable or word timing).
		case richsync
		/// Timed lines, no timing inside them.
		case synced
		/// Unsynced text: every time is 0.
		case none
	}

	/// A timed syllable or word of a ``Line``.
	public struct Part: Codable, Sendable, Hashable {
		public let startTimeMs: Double
		public let durationMs: Double
		/// The text, with the space that follows it when the source had one (`"Hel"`, `"lo "`).
		public let words: String
		/// A background vocal, sung over the main line (shown smaller, after it).
		public let isBackground: Bool?
		/// Which of the line's background groups the part is in, counted from 0.
		public let backgroundGroup: Int?
		public let explicit: Bool?

		public init(startTimeMs: Double, durationMs: Double, words: String, isBackground: Bool? = nil, backgroundGroup: Int? = nil, explicit: Bool? = nil) {
			self.startTimeMs = startTimeMs
			self.durationMs = durationMs
			self.words = words
			self.isBackground = isBackground
			self.backgroundGroup = backgroundGroup
			self.explicit = explicit
		}

		/// Seconds from the start of the track.
		public var startTime: TimeInterval { startTimeMs / 1000 }
		/// Seconds from the start of the track.
		public var endTime: TimeInterval { (startTimeMs + durationMs) / 1000 }
		/// Whether this part is a background vocal.
		public var background: Bool { isBackground ?? false }
	}

	/// A translation of a line, in ``lang``.
	public struct Translation: Codable, Sendable, Hashable {
		public let text: String
		/// BCP 47 language of ``text``.
		public let lang: String

		public init(text: String, lang: String) {
			self.text = text
			self.lang = lang
		}
	}

	/// One lyric line.
	public struct Line: Codable, Sendable, Hashable {
		public let startTimeMs: Double
		public let durationMs: Double
		/// The whole line as text, background vocals included. Empty on an instrumental line.
		public let words: String
		public let key: String?
		/// Who sings it: `v1`, `v2`... (`v1000` is everyone). `v2` and the other even slots are the alternate voice.
		public let agent: String?
		/// A gap nobody sings over (no words): show it as a pause, never as a lyric.
		public let isInstrumental: Bool?
		/// Syllable/word timing; absent or empty on line-timed and unsynced lyrics.
		public let parts: [Part]?
		public let translation: Translation?
		public let translations: [String: String]?
		public let romanization: String?
		public let timedRomanization: [Part]?

		public init(startTimeMs: Double, durationMs: Double, words: String, key: String? = nil, agent: String? = nil, isInstrumental: Bool? = nil, parts: [Part]? = nil, translation: Translation? = nil, translations: [String: String]? = nil, romanization: String? = nil, timedRomanization: [Part]? = nil) {
			self.startTimeMs = startTimeMs
			self.durationMs = durationMs
			self.words = words
			self.key = key
			self.agent = agent
			self.isInstrumental = isInstrumental
			self.parts = parts
			self.translation = translation
			self.translations = translations
			self.romanization = romanization
			self.timedRomanization = timedRomanization
		}

		/// Seconds from the start of the track.
		public var startTime: TimeInterval { startTimeMs / 1000 }
		/// Seconds from the start of the track.
		public var endTime: TimeInterval { (startTimeMs + durationMs) / 1000 }
		/// Whether this line is an instrumental gap rather than a lyric.
		public var instrumental: Bool { isInstrumental ?? false }
		/// Whether an alternate voice sings it (an even `ttm:agent` slot, as `v2`).
		public var isAltVoice: Bool {
			guard let agent, agent != "v1000", let slot = Int(agent.dropFirst()) else { return false }
			return slot % 2 == 0
		}
		/// The main vocal's timed parts.
		public var mainParts: [Part] { (parts ?? []).filter { !$0.background } }
		/// The background vocal's timed parts.
		public var backgroundParts: [Part] { (parts ?? []).filter(\.background) }
		/// The main vocal as text (``words`` without the background vocal, when the line is timed by parts).
		public var mainText: String {
			let main = mainParts
			guard !main.isEmpty else { return words.trimmingCharacters(in: .whitespacesAndNewlines) }
			return main.map(\.words).joined().trimmingCharacters(in: .whitespacesAndNewlines)
		}
		/// The background vocal as text, or `nil` when the line has none.
		public var backgroundText: String? {
			let background = backgroundParts.map(\.words).joined().trimmingCharacters(in: .whitespacesAndNewlines)
			return background.isEmpty ? nil : background
		}
	}

	/// What a provider's licence asks to be shown with its lyrics. Today only Unison's, which requires crediting
	/// Unison and the person who submitted the lyrics, each linked to their page, by 7 February 2027.
	public struct Credit: Codable, Sendable, Hashable {
		/// Who submitted the lyrics, with the link to their page.
		public struct Submitter: Codable, Sendable, Hashable {
			public let name: String
			public let url: URL

			public init(name: String, url: URL) {
				self.name = name
				self.url = url
			}
		}

		/// `Lyrics from Unison`; show it linked to ``url``.
		public let text: String
		/// The provider's page for this song, where a wrong line can be voted on, reported or fixed.
		public let url: URL
		/// The submitter, when the provider names one.
		public let submitter: Submitter?

		public init(text: String, url: URL, submitter: Submitter? = nil) {
			self.text = text
			self.url = url
			self.submitter = submitter
		}
	}

	/// The service that provided these lyrics.
	public let provider: LyricsProvider

	/// How ``lyrics`` are timed.
	public let syncType: SyncType

	/// The lines, in order (Braccato's `Lyric[]`). Instrumental gaps are lines of their own (``Line/instrumental``).
	public let lyrics: [Line]

	/// Who wrote the song, as the lyrics file credits them (empty when it says nothing).
	public let songwriters: [String]

	/// BCP 47 language the lyrics file declares, when it does.
	public let language: String?

	/// Milliseconds the lyrics are shown later (negative: earlier) than their own timing. Set with
	/// `Library.setLyricsOffset(id:offsetMs:)`; shared by everyone who can play the track and kept by the server with
	/// the cached lyrics (20 minutes).
	public let offsetMs: Int

	/// The credit to show with the lyrics, when the provider's licence requires one (`nil` otherwise).
	public let credit: Credit?

	public init(provider: LyricsProvider, syncType: SyncType, lyrics: [Line], songwriters: [String] = [], language: String? = nil, offsetMs: Int = 0, credit: Credit? = nil) {
		self.provider = provider
		self.syncType = syncType
		self.lyrics = lyrics
		self.songwriters = songwriters
		self.language = language
		self.offsetMs = offsetMs
		self.credit = credit
	}

	/// ``offsetMs`` in seconds: a line is sung at `line.startTime + offset` on the playback clock.
	public var offset: TimeInterval { Double(offsetMs) / 1000 }

	/// Whether the lines are timed at all.
	public var isSynced: Bool { syncType != .none }

	/// Whether the lines are timed syllable by syllable (or word by word).
	public var isRichSynced: Bool { syncType == .richsync }
}

/// The lyric offset of a track, returned by `Library.setLyricsOffset(id:offsetMs:)`.
public struct LyricsOffset: Codable, Sendable, Hashable {
	/// Milliseconds the lyrics are shown later (negative: earlier) than their own timing, within ±30000.
	public let offsetMs: Int

	public init(offsetMs: Int) {
		self.offsetMs = offsetMs
	}
}
