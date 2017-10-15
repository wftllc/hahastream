import Foundation

class ContentItem: NSObject, FromDictable {
	public var game: Game?
	public var channel: Channel?
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "\(self).<root>") }
		
		let kind: String = try dict.value("kind")
		if kind == "channel" {
			return self.init(channel: try Channel.fromDictionary(dict))
		}
		else if kind == "game" {
			return self.init(game: try Game.fromDictionary(dict))
		}
		else {
			throw FromDictableError.keyError(key: "kind unrecognized \(kind)")
		}
	}
	required init(game: Game? = nil, channel: Channel? = nil) {
		self.game = game
		self.channel = channel
	}
	
	override var description: String {
		if let g = game {
			return g.description
		}
		else {
			return channel!.description
		}
	}
}
