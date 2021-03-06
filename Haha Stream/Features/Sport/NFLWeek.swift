import Foundation


struct NFLWeek {
	var year: Int
	var type: NFLWeekType
	var week: Int
	var title: String { get {
		if type == .preSeason && week == 0 {
			return "\(year) Hall of Fame Game"
		}
		else if type == .preSeason {
			return "\(year) \(type.title) Week \(week)"
		}
		else if type == .regularSeason {
			return "\(year) Week \(week)"
		}
		else if let postseasonWeek = NFLPostseasonWeek(rawValue: week) {
			return "\(year) \(postseasonWeek.title)"
		}
		else {
			return "\(year) \(type.title) \(week)"
		}
		}}
}

enum NFLWeekType: Int {
	case preSeason =  1, regularSeason, playoffs
	
	var title: String { get {
		switch self {
		case .preSeason:
			return "Pre-Season"
		case .regularSeason:
			return "Regular Season"
		case .playoffs:
			return "Playoffs"
		}
		}}

	var weeks: CountableClosedRange<Int> { get {
		switch self {
		case .preSeason:
			return 0...4
		case .regularSeason:
			return 1...17
		case .playoffs:
			return NFLPostseasonWeek.wildCard.rawValue...NFLPostseasonWeek.superbowl.rawValue
		}
		}
	}
}


enum NFLPostseasonWeek: Int {
	case wildCard = 18, divisional, conference, probowl, superbowl
	var title: String { get {
		switch self {
		case .wildCard:
			return "Wild-Card Weekend"
		case .divisional:
			return "Divisional Playoffs"
		case .conference:
			return "Conference Championships"
		case .probowl:
			return "Pro Bowl"
		case .superbowl:
			return "Super Bowl"
		}}
	}
}
