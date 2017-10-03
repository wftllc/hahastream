import Foundation

/*
"uuid": "44c7d1b836badda9",
"home_team": {
"display_name": "Brooklyn Brooklyn",
"logo_url": "http://logos.hehestreams.xyz/image/nba_teams/brooklyn-nets.png"
},
"away_team": {
"display_name": "Toronto Toronto",
"logo_url": "http://logos.hehestreams.xyz/image/nba_teams/toronto-raptors.png"
},
"free": false,
"ready": false,
"start": "2017-01-17T19:30:00.000-05:00",
"title": "Toronto Toronto @ Brooklyn Brooklyn",
"title_without_date": "Toronto Toronto @ Brooklyn Brooklyn"
*/

final class Game: NSObject, FromDictable {
	let MaximumTimeIntervalToBeConsideredActive:TimeInterval = -4*60*60;
	
	public var uuid: String;
	public var title: String;
	public var ready: Bool;
	public var startDate: Date;
	public var free: Bool;
	
	public var homeTeam: String?;
	public var homeTeamLogoURL: URL?;
	public var awayTeam: String?;
	public var awayTeamLogoURL: URL?;
	
	public var sport: Sport!;
	
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
	
	//TODO: move team to its own class
	
	static func fromDictionary(_ dict:[String: Any]) -> Game? {
		guard let uuid = dict["uuid"] as? String else { return nil }
		
		let free = dict["free"] as? Bool ?? false
		guard let ready = dict["live"] as? Bool else { return nil }
		guard let title = dict["title"] as? String else { return nil }
		guard let startDateString = dict["start_in_gmt"] as? String else { return nil }
		guard let date = self.dateFormatter.date(from: startDateString) else { return nil }
		
		let homeTeamDict = dict["home"] as? [String: Any]
		let homeTeam = homeTeamDict?["name"] as? String
		let homeTeamLogoURL = URL(string: (homeTeamDict?["logo_url"] as? String ?? ""))
		let awayTeamDict = dict["away"] as? [String: Any]
		let awayTeam = awayTeamDict?["name"] as? String
		let awayTeamLogoURL = URL(string: (awayTeamDict?["logo_url"] as? String ?? ""))
		return Game.init(uuid: uuid,
		                 title: title,
		                 ready: ready,
		                 startDate: date,
		                 free: free,
		                 homeTeam: homeTeam,
		                 homeTeamLogoURL: homeTeamLogoURL,
		                 awayTeam: awayTeam,
		                 awayTeamLogoURL: awayTeamLogoURL
		);
	}
	
	init(uuid: String,
	     title: String,
	     ready: Bool,
	     startDate: Date,
	     free: Bool,
	     homeTeam: String?,
	     homeTeamLogoURL: URL?,
	     awayTeam: String?,
	     awayTeamLogoURL: URL?
		) {
		self.uuid = uuid;
		self.homeTeam = homeTeam;
		self.homeTeamLogoURL = homeTeamLogoURL;
		self.awayTeam = awayTeam;
		self.awayTeamLogoURL = awayTeamLogoURL;
		self.free = free;
		self.ready = ready;
		self.title = title;
		self.startDate = startDate;
	}
	
	override var description : String {
		return "\(title); \(awayTeam ?? "Away") @ \(homeTeam ?? "Home"), \(ready), \(startDate)";
	}
	
	public func cutNameInHalf(_ theName: String?) -> String? {
		guard let name = theName else { return nil }
		let halfwayPoint = (name.characters.count - 1) / 2
		let halfwayIndex = name.index(name.startIndex, offsetBy: halfwayPoint)
		let fixedHomeTeam = name[...halfwayIndex]
//		let fixedHomeTeam = name.substring(to:halfwayIndex)
		return String(fixedHomeTeam)
	}
	public var homeTeamName: String? {
		return cutNameInHalf(homeTeam);
	}
	
	public var awayTeamName: String? {
		return cutNameInHalf(awayTeam);
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

