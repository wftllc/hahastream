import Foundation

/*
[{
"uuid": "wn9bUH",
"name": "MLB Network",
"logo_url": "",
"kind": "channel",
"url": "/channels/wn9bUH.json",
"title": "MLB Network"
}

OR

[{
"uuid": "cZhswn",
"name": "ABC OnDemand",
"logo_url": "http://epg-image.totsuko.tv/epg-images/channel/25346/abcOnDemand_440x330_SIZE_220.png",
"kind": "channel",
"url": "/channels/cZhswn.json",
"title": "ABC OnDemand"
}, {
*/
class Channel: NSObject, FromDictable {
	public var uuid: String;
	public var title: String;
	public var path: String
	public var sport: Sport?
	public var logoURL: URL?

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		return try self.init(dict: dict);
	}
	
	required public init(dict:[String: Any]?) throws {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		self.uuid = try dict.value("uuid")
		self.title = try dict.value("title")
		self.path = try dict.value("url")
		self.logoURL = try? dict.value("logo_url")
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
