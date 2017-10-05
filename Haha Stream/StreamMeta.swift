import Foundation

final class StreamMeta: NSObject, FromDictable {
	public var streams: [Stream]
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		let dicts:[[String: Any]] = try dict.value("streams")
		var a: [Stream] = []
		for d in dicts {
			a.append(try Stream.fromDictionary(d))
		}
		return self.init(streams: a);
	}
	
	required public init(streams: [Stream]) {
		self.streams = streams
	}
	
	override var description : String {
		return "\(streams)";
	}
}
