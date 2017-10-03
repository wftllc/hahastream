import Foundation

final class StreamMeta: NSObject, FromDictable {
	public var streams: [Stream]
	
	static func fromDictionary(_ dict:[String: Any]) -> StreamMeta? {
		//TODO: make this nicer.
		guard let dicts = dict["streams"] as? [[String: Any]] else { return nil }
		var a: [Stream] = []
		for d in dicts {
			a.append(Stream.fromDictionary(d)!)
		}
		return StreamMeta(streams: a);
	}
		
	required public init(streams: [Stream]) {
		self.streams = streams
	}
	
	override var description : String {
		return "\(streams)";
	}
}
