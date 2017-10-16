import Foundation

/*
"id":761,
"name":"Lakers",
"league_id":null,
"location":"Los Angeles",
"abbreviation":"LAL",
"logo":"/images/teams/nba/LAL.svg"
*/

final class Team: NSObject, FromDictable {
	public var id: Int;
	public var name: String?
	public var location: String?
	public var abbreviation: String?

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		return try self.init(dict: dict)
	}
	
	required public init(dict: [String: Any]?) throws {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		self.id = try dict.value("id")
		self.name = try? dict.value("name")
		self.location = try? dict.value("location")
		self.abbreviation = try? dict.value("abbreviation")
	}
	
	required init(id: Int, name: String, location: String?, abbreviation: String?) {
		self.id = id;
		self.name = name
		self.location = location
		self.abbreviation = abbreviation
	}
	
	override var description : String {
		let s = name ?? abbreviation ?? "unknown team"
		return "\(s)";
	}
}

