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
	public var name: String
	public var location: String?
	public var abbreviation: String?

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }

		let id:Int = try dict.value("id")
		let name: String = try dict.value("name")
		let location: String? = try? dict.value("location")
		let abbreviation: String? = try? dict.value("abbreviation")
		return self.init(id: id, name: name, location: location, abbreviation: abbreviation)
	}
	
	required public init(id: Int, name: String, location: String?, abbreviation: String?) {
		self.id = id;
		self.name = name
		self.location = location
		self.abbreviation = abbreviation
	}
	
	override var description : String {
		return "\(name)";
	}
}

