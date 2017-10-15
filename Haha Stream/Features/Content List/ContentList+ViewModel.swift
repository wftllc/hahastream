//
//  ContentList+ViewModel.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/15/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import Foundation

extension ContentList {
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
		if self.channels.count > 0 {
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
	

}
