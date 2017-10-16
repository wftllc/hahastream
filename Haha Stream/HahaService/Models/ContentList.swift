import Foundation

class ContentList: NSObject {
	var date: Date?
	var nflWeek: NFLWeek?
	var nowPlaying: [ContentItem] = []
	var channels: [ContentItem] = []
	var upcoming: [ContentItem] = []
	var ended: [ContentItem] = []
	
	convenience init(date: Date? = nil, nowPlaying: [ContentItem], channels: [ContentItem], upcoming: [ContentItem], ended: [ContentItem]) {
		self.init()
		self.date = date
		self.nowPlaying = nowPlaying
		self.channels = channels
		self.upcoming = upcoming
		self.ended = ended
	}
	
	func merge(withContentList contentList: ContentList) {
		nowPlaying.append(contentsOf: contentList.nowPlaying)
		nowPlaying = nowPlaying.sorted(by: ContentList.gameSort)
		channels.append(contentsOf: contentList.channels)
		channels = channels.sorted(by: ContentList.channelSort)
		upcoming.append(contentsOf: contentList.upcoming)
		upcoming = upcoming.sorted(by: ContentList.gameSort)
		ended.append(contentsOf: contentList.ended)
		ended = ended.sorted(by: ContentList.gameSort)
	}
	
	class func contentList(bySortingItems items: [ContentItem]) -> ContentList {
		var active: [ContentItem] = []
		var channels: [ContentItem] = []
		var upcoming: [ContentItem] = []
		var ended: [ContentItem] = []
		
		items.forEach { (item) in
			if let game = item.game {
				if game.isActive {
					active.append(item)
				}
				else if game.isUpcoming {
					upcoming.append(item)
				}
				else {
					ended.append(item)
				}
			}
			else if let _ = item.channel {
				channels.append(item)
			}
		}
		//this goes like: current games => channels => upcoming games
		
		active = active.sorted(by: gameSort)
		upcoming = upcoming.sorted(by: gameSort)
		ended = ended.sorted(by: gameSort)
		channels = channels.sorted(by: channelSort)
		
		return ContentList(nowPlaying: active, channels: channels, upcoming: upcoming, ended: ended)
	}
	
	private class func gameSort(_ a: ContentItem, _ b: ContentItem) -> Bool {
		guard let a = a.game, let b = b.game else {
			return false
		}
		if a.isActive || a.isUpcoming {
			if a.startDate != b.startDate {
				return a.startDate < b.startDate
			}
		}
		if a.sport.name != b.sport.name {
			return a.sport.name < b.sport.name;
		}
		if let a = a.homeTeam.abbreviation, let b = b.homeTeam.abbreviation {
			return a < b
		}
		if a.title < b.title {
			return true
		}
		
		return false;
	}
	
	private class func channelSort(_ a: ContentItem, _ b: ContentItem) -> Bool {
		guard let a = a.channel, let b = b.channel else {
			return false
		}
		return a.title < b.title
	}
	
}
