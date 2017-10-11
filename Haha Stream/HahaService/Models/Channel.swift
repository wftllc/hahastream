import Foundation

class Channel: NSObject, FromDictable {
	public var uuid: String;
	public var title: String;
	public var path: String
	public var sport: Sport?

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }

		let uuid:String = try dict.value("uuid")
		let title: String = try dict.value("title")
		let path:String = try dict.value("url")
		return self.init(uuid: uuid, title: title, path: path);
	}
		
	required public init(uuid: String, title: String, path: String) {
		self.uuid = uuid
		self.title = title;
		self.path = path;
	}
	
	override var description : String {
		let sportName = sport?.name ?? "<no sport>"
		return "\(title), \(path), \(uuid), \(sportName)";
	}
	
	public var playActionURL: URL? {
		//TODO: url escape
		return URL(string: "hahastream://play/channel/\(uuid)")
	}
	
	public var displayActionURL: URL? {
		return URL(string: "hahastream://open/channel/\(uuid)")
	}
}
