// Made by Lumaa

import Foundation

/// A highlight-reel manifest for one of the requesting user's years, from `Insights.reel(year:)`.
///
/// Drives the in-app story player: ordered slides with headline statistics, cover art, and an audio
/// excerpt offset per top track. Also reports the status of the optional server-rendered MP4.
public struct HighlightReel: Codable, Sendable, Hashable {
	/// The reel's year.
	public let year: Int

	/// The reel's ordered slides.
	public let slides: [ReelSlide]

	/// Up to 9 cover-art URLs for the share card / collage.
	public let collage: [String]

	/// The status of the optional server-rendered MP4.
	public let reelStatus: ReelStatus

	/// The rendering failure's error message, if ``reelStatus`` is ``ReelStatus/failed``.
	public let reelError: String?

	/// Whether the MP4 is downloadable from `Insights.reelVideo(year:token:)`.
	public let hasVideo: Bool

	public init(year: Int, slides: [ReelSlide], collage: [String], reelStatus: ReelStatus, reelError: String?, hasVideo: Bool) {
		self.year = year
		self.slides = slides
		self.collage = collage
		self.reelStatus = reelStatus
		self.reelError = reelError
		self.hasVideo = hasVideo
	}
}
