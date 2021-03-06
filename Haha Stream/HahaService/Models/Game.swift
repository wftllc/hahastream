import Foundation


class Game: NSObject, FromDictable {
	let MaximumTimeIntervalToBeConsideredActive:TimeInterval = -4*60*60;

	public var uuid: String;
	public var title: String;
	private var ready: Bool;
	private var isReady: Bool { get {
		return ready || readyDate <= Date()
	}}
	private var ended: Bool
	public var startDate: Date;
	public var readyDate: Date;
	public var free: Bool;
	public var homeTeam: Team;
	public var awayTeam: Team;
	public var sport: Sport;
	
	public var isActive: Bool {
		return isReady && startDate.timeIntervalSinceNow > MaximumTimeIntervalToBeConsideredActive
	}
	
	public var isUpcoming: Bool {
		return startDate.timeIntervalSinceNow > 0;
	}
	
	public var startTimeString: String {
		return Game.timeFormatter.string(from: startDate)
	}
	
	static var dateFormatter: ISO8601DateFormatter = {
		let df = ISO8601DateFormatter();
		df.formatOptions = [.withFullDate, .withTime, .withDashSeparatorInDate, .withColonSeparatorInTime]
		return df;
	}()
	
	static var timeFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.autoupdatingCurrent
		df.timeStyle = .short
		df.dateStyle = .none
		return df;
	}()
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		let uuid: String = try dict.value("uuid")
		let ready: Bool = (try? dict.value("live")) ?? false
		let ended: Bool = try dict.value("ended")
		let title: String = try dict.value("title")
		let sportDict: [String: Any] = try dict.value("sport")
		let sport = try Sport.fromDictionary(sportDict)
		
		let startDateString: String = try dict.value("start_in_gmt")
		guard let date = self.dateFormatter.date(from: startDateString) else {
			throw FromDictableError.otherError(reason: "couldn't parse start_in_gmt")
		}
		
		let readyDateString: String = try dict.value("ready_at")
		guard let readyDate = self.dateFormatter.date(from: readyDateString) else {
			throw FromDictableError.otherError(reason: "couldn't parse ready_at")
		}
		

		
		let homeTeam: Team = try Team.fromDictionary(dict.value("home_team"))
		let awayTeam: Team = try Team.fromDictionary(dict.value("away_team"))
		
		return self.init(uuid: uuid,
		                 sport: sport,
		                 title: title,
		                 ready: ready,
		                 ended: ended,
		                 startDate: date,
		                 readyDate: readyDate,
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
	     readyDate: Date,
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
		self.readyDate = readyDate;
	}
	
	override var description : String {
		return "\(title)";
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

