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
	
	static func fromDictionary(_ dict:[String: Any]) -> Channel? {
		print(dict)
		guard let identifier = dict["id"] as? Int else { return nil }
		guard let title = dict["title"] as? String else { return nil }
		let notes = dict["notes"] as? String
		guard let active = dict["active"] as? Bool else { return nil }
		return Channel(identifier:identifier, title: title, notes: notes, active: active);
	}
		
	required public init(identifier: Int, title: String, notes: String?, active: Bool) {
		self.identifier = identifier;
		self.title = title;
		self.notes = notes;
		self.active = active;
	}
	
	override var description : String {
		return "\(title), \(identifier), \(active), \(notes)";
	}
}
