// Made by Lumaa

import Foundation

/// API endpoints under the `/api/v1/insights` path.
public enum Insights: NafynEndpoint {

	/// Side-by-side totals for several years of the requesting user's listening, including minutes per
	/// month so two years can be overlaid on one chart. Defaults to the most recent years with data.
	///
	/// Returns `[`` YearComparisonEntry``]`.
	/// - Parameter years: Comma-separated years to compare, e.g. `"2024,2025,2026"`.
	case compareYears(years: String? = nil)

	/// Ingest a batch of play events for the requesting user.
	///
	/// Idempotent: an event whose `eventId` already exists is silently ignored, so a client may safely
	/// retry a flush. Events are discarded (not rejected) when the user's Listening History setting is
	/// off, and events for tracks outside the user's library are never recorded. Returns ``IngestPlayEventsResponse``.
	/// - Parameters:
	///   - events: The batch of play events to ingest.
	///   - token: Auth token, as a fallback for `navigator.sendBeacon`, which cannot set headers.
	case ingestEvents(events: [PlayEventInput], token: String? = nil)

	/// Full export of the requesting user's listening data: raw play events, aggregates, Replay Mixes,
	/// and year-end snapshots, as a downloadable JSON document.
	///
	/// Always scoped to the caller. Returns raw `Data` — send this with ``NafynServer/sendRaw(_:)``,
	/// not ``NafynServer/send(_:)``: the spec leaves the response schema untyped (see "Known spec
	/// ambiguities" in this package's documentation), and its shape is versioned by a `format` field
	/// inside the document rather than by this client.
	case export

	/// Permanently erase the requesting user's entire listening history: raw play events, every
	/// aggregate, their Replay Mixes, their year-end snapshots, and any rendered highlight reels.
	///
	/// Irreversible, and scoped to the caller only. The Listening History setting itself is left as-is.
	/// Returns ``DeletedResponse``.
	case deleteHistory

	/// Tracks played and minutes listened per hour of day, for the requesting user. Always returns 24 points.
	///
	/// Hours are the user's local time, fixed when the data was rolled up. Returns `[`` HourPoint``]`.
	/// - Parameters:
	///   - period: Time window; `"all"` covers every year with data. Defaults to `"year"` server-side. The
	///     spec leaves this parameter's allowed values undocumented (empty `enum`), so it's a plain `String` here.
	///   - week: ISO week, e.g. `"2026-W35"`, when `period` is `"week"`.
	///   - month: `YYYY-MM`, when `period` is `"month"`.
	///   - year: Four-digit year, when `period` is `"year"`.
	case hourly(period: String? = nil, week: String? = nil, month: String? = nil, year: Int? = nil)

	/// Highlight-reel manifest for one of the requesting user's years.
	///
	/// Returns ``HighlightReel``.
	/// - Parameter year: The year.
	case reel(year: Int)

	/// Request the optional server-rendered MP4 of the requesting user's highlight reel for a year: a
	/// montage of the year's top tracks' album art with short audio excerpts and the headline numbers burnt in.
	///
	/// Rendering is opt-in and queued — reels are produced one at a time. Poll ``reel(year:)`` for
	/// progress; requesting a reel already queued or rendering is a no-op. Returns ``RequestReelVideoResponse``.
	/// - Parameter year: The year.
	case requestReelVideo(year: Int)

	/// Download the requesting user's rendered highlight-reel MP4 for a year.
	///
	/// Only ever serves the caller's own reel. Returns raw `Data` — send this with
	/// ``NafynServer/sendRaw(_:)``, not ``NafynServer/send(_:)``.
	/// - Parameters:
	///   - year: The year.
	///   - token: Auth token, for clients that can't set the Authorization header (e.g. `<video>` elements).
	case reelVideo(year: Int, token: String? = nil)

	/// An archived Replay Mix for the requesting user: a past year, or the All-Time mix.
	///
	/// Archived years are never rebuilt — they are the mix as it stood at the end of that year.
	/// Read-only, like every Replay Mix. Returns ``ReplayMix``.
	/// - Parameter year: A four-digit year, or the literal `"all-time"`.
	case archivedReplayMix(year: String)

	/// The requesting user's live Replay Mix for the current year: their top 100 tracks, rebuilt every Monday.
	///
	/// Read-only by design — it is not a row in the playlists table, so no playlist endpoint (and no
	/// admin) can rename, reorder, add to, or delete it. Returns ``ReplayMix``.
	case replayMix

	/// The requesting user's listening-history preferences.
	///
	/// Always scoped to the caller. Returns ``InsightsSettings``.
	case settings

	/// Turn the requesting user's listening history on or off.
	///
	/// Switching it off stops new events being accepted immediately, but does not delete anything
	/// already recorded — use ``deleteHistory`` for that. Returns ``InsightsSettings``.
	/// - Parameters:
	///   - historyEnabled: Whether to record listening history.
	///   - tzOffsetMinutes: Minutes to add to UTC to reach local time, clamped to `[-720, 840]`. Only stored when present.
	case updateSettings(historyEnabled: Bool? = nil, tzOffsetMinutes: Int? = nil)

	/// Monthly listening summary for the requesting user, with the previous month's totals for comparison.
	///
	/// Months are the user's local calendar months. Defaults to the month in progress. Returns ``MonthlyInsights``.
	/// - Parameter month: `YYYY-MM`. Defaults to the current month server-side.
	case monthly(month: String? = nil)

	/// Weekly listening summary for the requesting user, with the previous week alongside it for comparison.
	///
	/// Weeks are ISO-8601 (Monday-based) in the user's own time zone. Defaults to the week in progress.
	/// Returns ``WeeklyInsights``.
	/// - Parameter week: ISO week, e.g. `"2026-W35"`. Defaults to the current week server-side.
	case weekly(week: String? = nil)

	/// Yearly listening summary for the requesting user.
	///
	/// Live from the aggregates all year; once the year-end snapshot has been taken (start of December)
	/// the frozen copy is returned instead. Returns ``YearlyInsights``.
	/// - Parameter year: Four-digit year. Defaults to the current year server-side.
	case yearly(year: Int? = nil)

	/// Full ranked list of the requesting user's top tracks, albums, artists, or playlists for a period, paginated.
	///
	/// Month and year periods read precomputed ranks; week and all-time are computed on the fly. Returns
	/// `[`` RankedEntity``]`. The spec leaves the response schema fully untyped (`{}`), so this decodes as
	/// a bare array; revisit against a live server if that turns out wrong.
	/// - Parameters:
	///   - type: The entity kind to rank.
	///   - period: The time window. The spec leaves this parameter's allowed values undocumented (empty
	///     `enum`), so it's a plain `String` here.
	///   - week: `YYYY-Www`, when `period` is `"week"`. Defaults to the current week server-side.
	///   - month: `YYYY-MM`, when `period` is `"month"`. Defaults to the current month server-side.
	///   - year: Four-digit year, when `period` is `"year"`. Defaults to the current year server-side.
	case top(type: RankedEntityKind, period: String, week: String? = nil, month: String? = nil, year: Int? = nil)

	public var path: String {
		switch self {
			case .compareYears:
				return "/api/v1/insights/compare"
			case .ingestEvents:
				return "/api/v1/insights/events"
			case .export:
				return "/api/v1/insights/export"
			case .deleteHistory:
				return "/api/v1/insights/history"
			case .hourly:
				return "/api/v1/insights/hourly"
			case .reel(let year), .requestReelVideo(let year):
				return "/api/v1/insights/reel/\(year)"
			case .reelVideo(let year, _):
				return "/api/v1/insights/reel/\(year)/asset"
			case .archivedReplayMix(let year):
				return "/api/v1/insights/replay/\(year)"
			case .replayMix:
				return "/api/v1/insights/replay"
			case .settings, .updateSettings:
				return "/api/v1/insights/settings"
			case .monthly:
				return "/api/v1/insights/summary/monthly"
			case .weekly:
				return "/api/v1/insights/summary/weekly"
			case .yearly:
				return "/api/v1/insights/summary/yearly"
			case .top:
				return "/api/v1/insights/top"
		}
	}

	public var methods: [NafynServer.HTTPMethod] {
		switch self {
			case .ingestEvents, .requestReelVideo:
				return [.post]
			case .deleteHistory:
				return [.delete]
			case .updateSettings:
				return [.patch]
			case .compareYears, .export, .hourly, .reel, .reelVideo, .archivedReplayMix, .replayMix, .settings, .monthly, .weekly, .yearly, .top:
				return [.get]
		}
	}

	public var queries: [URLQueryItem] {
		switch self {
			case .compareYears(let years):
				guard let years else { return [] }
				return [URLQueryItem(name: "years", value: years)]
			case .ingestEvents(_, let token):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
			case .hourly(let period, let week, let month, let year):
				var items: [URLQueryItem] = []
				if let period {
					items.append(URLQueryItem(name: "period", value: period))
				}
				if let week {
					items.append(URLQueryItem(name: "week", value: week))
				}
				if let month {
					items.append(URLQueryItem(name: "month", value: month))
				}
				if let year {
					items.append(URLQueryItem(name: "year", value: String(year)))
				}
				return items
			case .reelVideo(_, let token):
				guard let token else { return [] }
				return [URLQueryItem(name: "token", value: token)]
			case .monthly(let month):
				guard let month else { return [] }
				return [URLQueryItem(name: "month", value: month)]
			case .weekly(let week):
				guard let week else { return [] }
				return [URLQueryItem(name: "week", value: week)]
			case .yearly(let year):
				guard let year else { return [] }
				return [URLQueryItem(name: "year", value: String(year))]
			case .top(let type, let period, let week, let month, let year):
				var items: [URLQueryItem] = [
					URLQueryItem(name: "type", value: type.rawValue),
					URLQueryItem(name: "period", value: period),
				]
				if let week {
					items.append(URLQueryItem(name: "week", value: week))
				}
				if let month {
					items.append(URLQueryItem(name: "month", value: month))
				}
				if let year {
					items.append(URLQueryItem(name: "year", value: String(year)))
				}
				return items
			default:
				return []
		}
	}

	public var body: AnyEncodable? {
		switch self {
			case .ingestEvents(let events, _):
				return AnyEncodable(IngestPlayEventsRequest(events: events))
			case .updateSettings(let historyEnabled, let tzOffsetMinutes):
				return AnyEncodable(UpdateInsightsSettingsRequest(historyEnabled: historyEnabled, tzOffsetMinutes: tzOffsetMinutes))
			default:
				return nil
		}
	}
}

struct IngestPlayEventsRequest: Encodable, Sendable {
	let events: [PlayEventInput]
}

struct UpdateInsightsSettingsRequest: Encodable, Sendable {
	let historyEnabled: Bool?
	let tzOffsetMinutes: Int?
}
