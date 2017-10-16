//
//  ContentList+ViewModel.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/15/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import Foundation

extension ContentList {
	var dateFormatter: DateFormatter {
		let df = DateFormatter();
		df.locale = Locale.current;
		df.dateStyle = .long;
		df.timeStyle = .none;
		return df;
	}

	enum Section {
		case nowPlaying
		case channels
		case upcoming
		case ended
	}

	var sections: [Section] {
		var a: [Section] = []
		if self.nowPlaying.count > 0 {
			a.append(.nowPlaying)
		}
		//only show channels if we're looking at the "right now" content list
		if self.channels.count > 0 && self.date == nil && self.nflWeek == nil {
			a.append(.channels)
		}
		if self.upcoming.count > 0 {
			a.append(.upcoming)
		}
		if self.ended.count > 0 {
			a.append(.ended)
		}
		return a
	}
	
	func indexPath(forItem item: ContentItem) -> IndexPath? {
		var sectionIndex = 0
		for _ in sections {
			var itemIndex = 0
			for otherItem in items(inSection: sectionIndex) {
				if item == otherItem {
					return IndexPath(item: itemIndex, section: sectionIndex)
				}
				itemIndex += 1
			}
			sectionIndex += 1
		}
		return nil
	}
	
	func items(inSection section: Int) -> [ContentItem] {
		let section = self.sections[section]
		switch section {
		case .nowPlaying:
			return self.nowPlaying
		case .channels:
			return self.channels
		case .upcoming:
			return self.upcoming
		case .ended:
			return self.ended
		}

	}
	
	func item(atIndexPath indexPath: IndexPath) -> ContentItem? {
		return self.items(inSection: indexPath.section)[indexPath.item]
	}
	
	var title: String {
		if let date = date {
			return self.dateFormatter.string(from: date)
		}
		else if let nflWeek = nflWeek {
			return nflWeek.title
		}
		else {
			return "Now Playing"
		}
	}

}
