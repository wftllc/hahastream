import Foundation


class Game: NSObject, FromDictable {
	let MaximumTimeIntervalToBeConsideredActive:TimeInterval = -4*60*60;
	
	public var uuid: String;
	public var title: String;
	public var ready: Bool;
	public var ended: Bool
	public var startDate: Date;
	public var free: Bool;
	public var homeTeam: Team;
	public var awayTeam: Team;
	public var sport: Sport;
	
	public var active: Bool {
		return ready && startDate.timeIntervalSinceNow > MaximumTimeIntervalToBeConsideredActive
	}
	
	public var upcoming: Bool {
		return startDate.timeIntervalSinceNow > 0 && !ready;
	}
	
	public var startTimeString: String {
		return Game.timeFormatter.string(from: startDate)
	}
	
	static var dateFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale(identifier: "en_US_POSIX");
		df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSZ'"
		return df;
	}()
	
	static var timeFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.autoupdatingCurrent
		df.timeStyle = .short
		df.dateStyle = .none
		return df;
	}()
	
//	//TODO: move team to its own class
//	init(dict:[String: Any]?) throws {
//		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
//		self.uuid = try dict.value("uuid");
//		
//	}
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		let uuid: String = try dict.value("uuid")
		let ready: Bool = (try? dict.value("live")) ?? false
		let ended: Bool = try dict.value("ended")
		let title: String = try dict.value("title")
		let sportDict: [String: Any] = try dict.value("sport")
		let sport = try Sport.fromDictionary(sportDict)
		
		let startDateString: String = try dict.value("start_in_gmt")
		guard let date = self.dateFormatter.date(from: startDateString) else { throw FromDictableError.otherError(reason: "couldn't parse start_in_gmt") }
		
		
		let homeTeam: Team = try Team.fromDictionary(dict.value("home_team"))
		let awayTeam: Team = try Team.fromDictionary(dict.value("away_team"))
		
		return self.init(uuid: uuid,
		                 sport: sport,
		                 title: title,
		                 ready: ready,
		                 ended: ended,
		                 startDate: date,
		                 free: false,
		                 homeTeam: homeTeam,
		                 awayTeam: awayTeam
		);
	}
	
	required init(uuid: String,
	     sport: Sport,
	     title: String,
	     ready: Bool,
	     ended: Bool,
	     startDate: Date,
	     free: Bool,
	     homeTeam: Team,
	     awayTeam: Team
		) {
		self.uuid = uuid;
		self.sport = sport
		self.homeTeam = homeTeam;
		self.awayTeam = awayTeam;
		self.free = free;
		self.ready = ready;
		self.ended = ended
		self.title = title;
		self.startDate = startDate;
	}
	
	override var description : String {
		return "\(title)";
	}
	
	
	public var homeTeamName: String {
		return self.homeTeam.name
	}
	
	public var awayTeamName: String {
		return self.awayTeam.name
	}
	
	public var singleImageURL: URL? {
		return URL(string: "https://logos.hehestreams.xyz/image/vue_channels/\(self.uuid).png")
	}
	
	public var playActionURL: URL? {
		//TODO: url escape
		return URL(string: "hahastream://play/game/\(self.sport.name)/\(self.uuid)")
	}
	
	public var displayActionURL: URL? {
		return URL(string: "hahastream://open/game/\(self.sport.name)/\(self.uuid)")
	}
}

