import UIKit

struct NowPlayingItem {
	public var game: Game?
	public var channel: Channel?
	init(game: Game) {
		self.game = game
	}
	init(channel: Channel) {
		self.channel = channel
	}
	
	var description: String {
		if let g = game {
			return g.description
		}
		else {
			return channel!.description
		}
	}
}
