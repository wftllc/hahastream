//
//  NowPlayingSections.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/13/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import Foundation

class Content: NSObject {
	
	var nowPlaying: [ContentItem] = []
	var channels: [ContentItem] = []
	var upcoming: [ContentItem] = []
	var ended: [ContentItem] = []
	
	convenience init(nowPlaying: [ContentItem], channels: [ContentItem], upcoming: [ContentItem], ended: [ContentItem]) {
		self.init()
		self.nowPlaying = nowPlaying
		self.channels = channels
		self.upcoming = upcoming
		self.ended = ended
	}
	
	func merge(withContent content: Content) {
		nowPlaying.append(contentsOf: content.nowPlaying)
		nowPlaying = nowPlaying.sorted(by: Content.gameSort)
		channels.append(contentsOf: content.channels)
		channels = channels.sorted(by: Content.channelSort)
		upcoming.append(contentsOf: content.upcoming)
		upcoming = upcoming.sorted(by: Content.gameSort)
		ended.append(contentsOf: content.ended)
		ended = ended.sorted(by: Content.gameSort)
	}
	
	
	class func content(bySortingItems items: [ContentItem]) -> Content {
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
		
		return Content(nowPlaying: active, channels: channels, upcoming: upcoming, ended: ended)
	}
	
	private class func gameSort(_ a: ContentItem, _ b: ContentItem) -> Bool {
		guard let a = a.game, let b = b.game else {
			return false
		}
		if a.startDate != b.startDate {
			return a.startDate < b.startDate
		}
		if a.sport.name != b.sport.name {
			return a.sport.name < b.sport.name;
		}
		if a.title < b.title {
			return true;
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
