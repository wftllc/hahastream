import Foundation

final class Channel: NSObject, FromDictable {
	/*
{
"id": 3,
"title": "NFL RedZone",
"active": false,
"notes": "Only broadcast on Sundays between 12PM and 8PM Eastern"
}
*/
	public var sport: Sport?
	public var identifier: Int;
	public var title: String;
	public var notes: String?;
	public var active: Bool;
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }

		let identifier:Int = try dict.value("id")
		let title: String = try dict.value("title")
		let notes:String? = try dict.value("notes")
		let active:Bool = try dict.value("active")
		return self.init(identifier:identifier, title: title, notes: notes, active: active);
	}
		
	required public init(identifier: Int, title: String, notes: String?, active: Bool) {
		self.identifier = identifier;
		self.title = title;
		self.notes = notes;
		self.active = active;
	}
	
	override var description : String {
		return "\(title), \(identifier), \(active), \(String(describing: notes), String(describing: notes))";
	}
	
	public var playActionURL: URL? {
		//TODO: url escape
		return URL(string: "hahastream://play/channel/\(self.sport!.name)/\(self.identifier)")
	}
	
	public var displayActionURL: URL? {
		return URL(string: "hahastream://open/channel/\(self.sport!.name)/\(self.identifier)")
	}
}
