// Made by Lumaa

import Testing
import Foundation
@testable import Safyn

/// Pure tests: endpoint shape and model decoding. No server needed, so these must always pass.
@Suite("Offline Endpoint & Model Checks")
struct OfflineTests {

	private func decoder() -> JSONDecoder {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .iso8601
		return decoder
	}

	private func query(_ endpoint: some NafynEndpoint) -> [String: String] {
		Dictionary(uniqueKeysWithValues: endpoint.queries.map { ($0.name, $0.value ?? "") })
	}

	// MARK: - Search

	@Test("Search with only a query sends only q")
	func searchMinimalQueries() {
		#expect(query(Search.search(q: "Daft Punk")) == ["q": "Daft Punk"])
	}

	@Test("Search sends title, artist, upc and isrc when given")
	func searchIdentityQueries() {
		let endpoint = Search.search(q: "x", title: "Get Lucky", artist: "Daft Punk", upc: "0886443919266", isrc: "USQX91300108", filter: .track, limit: 5, offset: 10)
		let sent = query(endpoint)
		#expect(sent["title"] == "Get Lucky")
		#expect(sent["artist"] == "Daft Punk")
		#expect(sent["upc"] == "0886443919266")
		#expect(sent["isrc"] == "USQX91300108")
		#expect(sent["filter"] == "track")
		#expect(sent["limit"] == "5.0")
		#expect(sent["offset"] == "10.0")
	}

	@Test("Search results decode bestResult and the match breakdown")
	func searchResultDecoding() throws {
		let json = """
		{"albums":[],"artists":[],"tracks":[{
			"id":"t1","title":"Get Lucky","artist":"Daft Punk","album":null,"type":"track","coverArt":null,
			"releaseDate":null,"inLibrary":false,"duration":248,"label":null,"bestResult":true,
			"match":{"title":1,"artist":0.9,"relevance":1.4,"exactness":1,"sources":3,"hasFrontCover":true,"flags":["isrc_match","brand_new_flag"]}
		}]}
		"""
		let result = try decoder().decode(SearchResult.self, from: Data(json.utf8))
		let track = try #require(result.tracks.first)
		#expect(track.bestResult == true)
		#expect(track.match?.sources == 3)
		#expect(track.match?.flags == [.isrcMatch, .unknown])
	}

	@Test("Search results without ranking fields still decode")
	func searchResultWithoutMatch() throws {
		let json = #"{"id":"t1","title":"A","artist":"B","album":null,"type":"track","coverArt":null,"releaseDate":null,"inLibrary":null,"duration":1,"label":null}"#
		let info = try decoder().decode(MediaInfo.self, from: Data(json.utf8))
		#expect(info.bestResult == nil)
		#expect(info.match == nil)
	}

	// MARK: - Track

	@Test("ISRC lookup sends no queries without a fallback")
	func isrcNoFallback() {
		let endpoint = Track.getByIsrc(isrc: "USRC17607839")
		#expect(endpoint.path == "/api/v1/track/isrc/USRC17607839")
		#expect(endpoint.queries.isEmpty)
	}

	@Test("ISRC lookup sends title and artist fallbacks")
	func isrcFallback() {
		let sent = query(Track.getByIsrc(isrc: "USRC17607839", title: "Get Lucky", artist: "Daft Punk"))
		#expect(sent == ["title": "Get Lucky", "artist": "Daft Punk"])
	}

	@Test("ISRC lookup sends the duration, and a nil ISRC goes to the placeholder path")
	func isrcDurationAndNil() {
		let sent = query(Track.getByIsrc(isrc: nil, title: "Get Lucky", artist: "Daft Punk", duration: 248))
		#expect(sent == ["title": "Get Lucky", "artist": "Daft Punk", "duration": "248"])
		#expect(Track.getByIsrc(isrc: nil, title: "Get Lucky", artist: "Daft Punk").path == "/api/v1/track/isrc/ZZZZZ0000000")
	}

	// MARK: - Import

	@Test("Import endpoints: paths, methods, queries")
	func importShape() {
		let create = Import.create(tracks: [ImportTrack(isrc: "USQX91300108", title: "Get Lucky", artist: "Daft Punk")], source: "apple-music")
		#expect(create.path == "/api/v1/import")
		#expect(create.methods == [.post])
		#expect(create.queries.isEmpty)
		#expect(Import.get(id: "abc").path == "/api/v1/import/abc")
		#expect(Import.get(id: "abc").methods == [.get])
		#expect(query(Import.all(page: 2, limit: 10)) == ["page": "2", "limit": "10"])
		#expect(Import.all().queries.isEmpty)
	}

	@Test("Import body carries the tracks and leaves out what is nil")
	func importBody() throws {
		let create = Import.create(tracks: [ImportTrack(isrc: nil, title: "Get Lucky", artist: "Daft Punk", duration: 248)], source: "apple-music", name: "Mix")
		let body = try #require(create.body)
		let json = try #require(try JSONSerialization.jsonObject(with: JSONEncoder().encode(body)) as? [String: Any])
		#expect(json["source"] as? String == "apple-music")
		#expect(json["name"] as? String == "Mix")
		let track = try #require((json["tracks"] as? [[String: Any]])?.first)
		#expect(track["title"] as? String == "Get Lucky")
		#expect(track["duration"] as? Int == 248)
		#expect(track["isrc"] == nil)
	}

	@Test("An import decodes its counts and items, unknown statuses included")
	func importDecoding() throws {
		let json = """
		{"id":"i1","source":"apple-music","name":null,"status":"running","total":3,"processed":2,
		 "counts":{"pending":1,"requested":1,"not-found":1},"createdAt":1793000000,"updatedAt":1793000060,
		 "items":[
		  {"position":0,"isrc":"USQX91300108","title":"Get Lucky","artist":"Daft Punk","album":null,"duration":248,"status":"requested","musicbrainzId":"r1","requestId":"q1","via":"isrc","message":null},
		  {"position":1,"isrc":null,"title":"x","artist":"y","album":null,"duration":null,"status":"not-found","musicbrainzId":null,"requestId":null,"via":null,"message":"No matching recording"},
		  {"position":2,"isrc":null,"title":"z","artist":"w","album":null,"duration":null,"status":"brand-new","musicbrainzId":null,"requestId":null,"via":"telepathy","message":null}
		 ]}
		"""
		let job = try decoder().decode(PlaylistImport.self, from: Data(json.utf8))
		#expect(job.status == .running)
		#expect(job.counts.notFound == 1)
		#expect(job.counts.alreadyRequested == 0)
		let items = try #require(job.items)
		#expect(items.map(\.status) == [.requested, .notFound, .unknown])
		#expect(items[0].via == .isrc)
		#expect(items[2].via == .unknown)
		#expect(job.createdDate == Date(timeIntervalSince1970: 1793000000))
	}

	@Test("Track.get has no queries")
	func trackGetQueries() {
		#expect(Track.get(tid: "abc").queries.isEmpty)
	}

	@Test("ISRC fallback response decodes searchFallback and inLibrary")
	func isrcFallbackDecoding() throws {
		let json = """
		{"id":"t1","title":"Get Lucky","artist":"Daft Punk","album":null,"type":"track","coverArt":null,
		 "releaseDate":null,"inLibrary":true,"duration":248,"label":null,"albumMbid":"a1","searchFallback":true}
		"""
		let detail = try decoder().decode(TrackDetail.self, from: Data(json.utf8))
		#expect(detail.searchFallback == true)
		#expect(detail.info.inLibrary == true)
		#expect(detail.albumMbid == "a1")
		#expect(detail.requested == nil)
	}

	@Test("Track.get response decodes release and request state")
	func trackDetailDecoding() throws {
		let json = """
		{"id":"t1","title":"X","artist":"Y","album":null,"type":"track","coverArt":null,"releaseDate":null,
		 "inLibrary":false,"duration":1,"label":null,"albumMbid":null,
		 "releaseDatePrecision":"month","released":false,"subscribed":true,"requested":false}
		"""
		let detail = try decoder().decode(TrackDetail.self, from: Data(json.utf8))
		#expect(detail.releaseDatePrecision == .month)
		#expect(detail.released == false)
		#expect(detail.subscribed == true)
		#expect(detail.requested == false)
		#expect(detail.searchFallback == nil)
	}

	@Test("TrackDetail survives an encode/decode round trip")
	func trackDetailRoundTrip() throws {
		let json = #"{"id":"t1","title":"X","artist":"Y","album":null,"type":"track","coverArt":null,"releaseDate":null,"inLibrary":false,"duration":1,"label":null,"albumMbid":"a","searchFallback":false}"#
		let detail = try decoder().decode(TrackDetail.self, from: Data(json.utf8))
		let encoder = JSONEncoder()
		encoder.dateEncodingStrategy = .iso8601
		let again = try decoder().decode(TrackDetail.self, from: try encoder.encode(detail))
		#expect(again == detail)
	}

	// MARK: - Album

	@Test("Album response decodes inLibrary and requested")
	func albumDetailDecoding() throws {
		let json = """
		{"id":"a1","releaseId":"r1","title":"RAM","artist":"Daft Punk","type":"album","coverArt":null,
		 "imageColors":["#000000"],"textColor":"white","releaseDate":null,"releaseDatePrecision":"year",
		 "released":true,"subscribed":false,"requested":true,"inLibrary":false,"description":null,"label":null,
		 "discs":[{"number":1,"title":null},{"number":2,"title":"Bonus"}],
		 "tracks":[{"id":"t1","title":"Get Lucky","trackNumber":8,"discNumber":2,"duration":248,"releaseDate":null,"released":true,"inLibrary":true,"requested":false,"mediaId":null}]}
		"""
		let album = try decoder().decode(AlbumDetail.self, from: Data(json.utf8))
		#expect(album.requested)
		#expect(!album.inLibrary)
		#expect(album.tracks.first?.inLibrary == true)
		#expect(album.discs.map(\.number) == [1, 2])
		#expect(album.discs.last?.title == "Bonus")
		#expect(album.tracks.first?.discNumber == 2)
	}

	@Test("Library album response decodes optional disc info")
	func libraryAlbumDiscs() throws {
		let album = """
		{"id":"a1","mbId":"a1","title":"RAM","artistName":"Daft Punk","artistMbid":null,"coverArt":null,
		 "releaseDate":null,"duration":1,"trackCount":1,"addedAt":0,"imageColors":[],"textColor":"white"}
		"""
		let track = """
		{"id":"m1","musicbrainzId":"t1","title":"X","artistName":"Y","artistMbid":null,"album":"RAM","albumId":"a1",
		 "albumType":"album","coverArt":null,"releaseDate":null,"duration":1,"label":null,"fingerprint":null,
		 "amId":null,"fileSize":null,"addedAt":0
		"""
		let withDiscs = """
		{"album":\(album),"discs":[{"number":1,"title":null},{"number":2,"title":"Bonus"}],
		 "tracks":[\(track),"discNumber":2,"trackNumber":3}]}
		"""
		let decoded = try decoder().decode(LibraryAlbumResponse.self, from: Data(withDiscs.utf8))
		#expect(decoded.discs?.map(\.number) == [1, 2])
		#expect(decoded.tracks.first?.discNumber == 2)
		#expect(decoded.tracks.first?.trackNumber == 3)

		let without = """
		{"album":\(album),"tracks":[\(track)}]}
		"""
		let plain = try decoder().decode(LibraryAlbumResponse.self, from: Data(without.utf8))
		#expect(plain.discs == nil)
		#expect(plain.tracks.first?.discNumber == nil)
	}

	// MARK: - Other endpoints

	@Test("Subscriptions endpoints use the right paths and methods")
	func subscriptionsShape() {
		#expect(Subscriptions.list.path == "/api/v1/subscriptions")
		#expect(Subscriptions.list.methods == [.get])
		#expect(Subscriptions.create(id: "x", type: .album, timezone: "Europe/Paris").methods == [.post])
		#expect(Subscriptions.delete(mbid: "x").path == "/api/v1/subscriptions/x")
		#expect(Subscriptions.delete(mbid: "x").methods == [.delete])
	}

	@Test("Privacy notice sends locale only when given")
	func privacyQueries() {
		#expect(Content.privacyNotice().queries.isEmpty)
		#expect(query(Content.privacyNotice(locale: "fr")) == ["locale": "fr"])
	}

	@Test("Request.all sends only the filters given")
	func requestFilterQueries() {
		#expect(Request.all().queries.isEmpty)
		let sent = query(Request.all(limit: 5, offset: 10, succeeded: false, failed: true, waiting: false, processing: true))
		#expect(sent == ["limit": "5", "offset": "10", "succeeded": "false", "failed": "true", "waiting": "false", "processing": "true"])
		#expect(query(Request.all(succeeded: false)) == ["succeeded": "false"])
	}

	@Test("Download limit endpoint uses the right path, method and body")
	func downloadLimitShape() throws {
		#expect(Settings.downloadLimit.path == "/api/v1/settings/downloads")
		#expect(Settings.downloadLimit.methods == [.get])
		#expect(Settings.downloadLimit.body == nil)
	}

	@Test("Download limit response decodes")
	func downloadLimitDecoding() throws {
		let limit = try decoder().decode(DownloadLimitResponse.self, from: Data(#"{"maxConcurrent": 3}"#.utf8))
		#expect(limit.maxConcurrent == 3)
	}

	@Test("Cover art endpoint builds its path and optional token")
	func coverArtShape() {
		let release = Library.coverArt(type: .release, id: "abc", size: .medium)
		#expect(release.path == "/api/v1/art/release/abc/500")
		#expect(release.methods == [.get])
		#expect(release.queries.isEmpty)
		let group = Library.coverArt(type: .releaseGroup, id: "abc", size: .small, token: "t")
		#expect(group.path == "/api/v1/art/release-group/abc/250")
		#expect(query(group) == ["token": "t"])
		#expect(Library.coverArt(type: .release, id: "abc", size: .large).path.hasSuffix("/1000"))
	}

	@Test("Artist endpoint path")
	func artistPath() {
		#expect(Artist.get(aid: "abc").path == "/api/v1/artist/abc")
	}

	@Test("Artist image endpoint path")
	func artistImagePath() {
		#expect(Artist.image(aid: "abc").path == "/api/v1/artist/abc/image")
		#expect(Artist.image(aid: "abc").methods == [.get])
	}

	@Test("Cover options endpoint sends albumId")
	func coverOptionsShape() {
		let endpoint = Library.coverOptions(albumId: "abc")
		#expect(endpoint.path == "/api/v1/library/cover-options")
		#expect(endpoint.methods == [.get])
		#expect(query(endpoint) == ["albumId": "abc"])
	}

	@Test("Library lists send q and sort only when given")
	func libraryListQueries() {
		#expect(Library.tracks().queries.isEmpty)
		#expect(Library.tracks(limit: 2, offset: 4).queries.count == 2)
		#expect(query(Library.tracks(query: "the strokes", sort: .artist)) == ["q": "the strokes", "sort": "artist"])
		#expect(query(Library.albums(limit: 10, query: "  new abnormal ", sort: .released)) == ["limit": "10", "q": "new abnormal", "sort": "released"])
		// blank search text is no search
		#expect(Library.tracks(query: "   ").queries.isEmpty)
		#expect(Library.albums(sort: .added).queries.map(\.value) == ["added"])
		#expect(LibrarySort.allCases.map(\.rawValue) == ["added", "title", "artist", "released"])
	}

	@Test("Change album endpoint builds its path, method and body")
	func changeAlbumShape() throws {
		let endpoint = Library.changeAlbum(id: "m1", albumId: "rg1")
		#expect(endpoint.path == "/api/v1/library/m1/album")
		#expect(endpoint.methods == [.put])
		#expect(endpoint.queries.isEmpty)
		let body = try #require(endpoint.body)
		let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(body)) as? [String: String]
		#expect(json == ["albumId": "rg1"])
	}

	@Test("Lyrics decode with every provider the server can name")
	func lyricsProviders() throws {
		for provider in ["manual", "betterLyrics", "unison", "cider", "lrclib", "cache"] {
			let json = #"{"provider":"\#(provider)","paragraphs":[]}"#
			let lyrics = try decoder().decode(Lyrics.self, from: Data(json.utf8))
			#expect(lyrics.provider.rawValue == provider)
		}
		#expect(throws: DecodingError.self) {
			_ = try decoder().decode(Lyrics.self, from: Data(#"{"provider":"appleMusic","paragraphs":[]}"#.utf8))
		}
	}

	@Test("Pins endpoints use the right paths, methods, queries and body")
	func pinsShape() throws {
		#expect(Pins.list.path == "/api/v1/pins")
		#expect(Pins.list.methods == [.get])
		#expect(Pins.list.queries.isEmpty)
		let pin = Pins.pin(kind: .playlist, refId: "p1")
		#expect(pin.path == "/api/v1/pins")
		#expect(pin.methods == [.post])
		#expect(pin.queries.isEmpty)
		let body = try #require(pin.body)
		let json = try JSONSerialization.jsonObject(with: JSONEncoder().encode(body)) as? [String: String]
		#expect(json == ["kind": "playlist", "refId": "p1"])
		let unpin = Pins.unpin(kind: .track, refId: "t1")
		#expect(unpin.methods == [.delete])
		#expect(unpin.body == nil)
		#expect(query(unpin) == ["kind": "track", "refId": "t1"])
	}

	@Test("Profile endpoint path")
	func profilePath() {
		#expect(Users.profile(username: "lumaa").path == "/api/v1/profile/lumaa")
		#expect(Users.profile(username: "lumaa").methods == [.get])
	}

	@Test("Pinned items, cover options, artist image and profiles decode")
	func newModelsDecoding() throws {
		let pins = try decoder().decode([PinnedItem].self, from: Data(#"""
		[{"kind":"playlist","refId":"p1","pinnedAt":1700000000000,"title":"Mix","subtitle":null,"href":"/playlist/p1","isOwner":true,"isMember":false,"playlistImage":"v2"},
		 {"kind":"track","refId":"t1","pinnedAt":1700000001000,"title":"Song","href":"/track/t1","coverMediaId":"t1","media":{"id":"t1"}}]
		"""#.utf8))
		#expect(pins.count == 2)
		#expect(pins[0].kind == .playlist && pins[0].isOwner == true && pins[0].playlistImage == "v2")
		#expect(pins[1].kind == .track && pins[1].media != nil && pins[1].isOwner == nil)
		#expect(pins[1].pinnedAtDate.timeIntervalSince1970 == 1_700_000_001)

		let options = try decoder().decode(CoverOptionsResponse.self, from: Data(#"""
		{"options":[{"id":"g","kind":"release-group","title":"A","url":"https://x/g.jpg"},{"id":"r","kind":"release","title":"A","details":"2020, FR","url":"https://x/r.jpg"}]}
		"""#.utf8))
		#expect(options.options.map(\.kind) == [.releaseGroup, .release])
		#expect(options.options[1].details == "2020, FR")

		#expect(try decoder().decode(ArtistImageResponse.self, from: Data(#"{"image":null}"#.utf8)).image == nil)
		#expect(try decoder().decode(PinResponse.self, from: Data(#"{"pinned":true}"#.utf8)).pinned == true)

		let profile = try decoder().decode(UserProfile.self, from: Data(#"""
		{"id":"u","username":"lumaa","displayName":null,"avatar":"v1","lastFm":"l","trackCount":42,
		 "playlists":[{"id":"p","title":"Mix","description":null,"trackCount":3,"updatedAt":1700000000000}]}
		"""#.utf8))
		#expect(profile.trackCount == 42 && profile.discogs == nil && profile.playlists.first?.trackCount == 3)
	}

	// MARK: - Sockets

	@Test("Unity socket requires an auth token")
	func unitySocketRequiresToken() {
		let instance = NafynInstance(appName: "SafynTests", baseURL: testURL, serverId: UUID(), serverDate: Date())
		let server = NafynServer(instance: instance)
		#expect(throws: NafynError.self) {
			_ = try server.unitySocket()
		}
	}

	@Test("Unity socket builds once authenticated")
	func unitySocketBuilds() throws {
		let instance = NafynInstance(appName: "SafynTests", baseURL: testURL, serverId: UUID(), serverDate: Date())
		let server = NafynServer(instance: instance, authToken: "test-token")
		_ = try server.unitySocket()
	}
}
