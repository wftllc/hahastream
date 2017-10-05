import Foundation

final class Sport: NSObject, FromDictable {
	public var name: String;
	public var path: String;
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		let name: String = try dict.value("name")
		let path: String = try dict.value("collection_endpoint")
		return self.init(name: name, path: path);
	}
		
	required public init(name: String, path: String) {
		self.name = name;
		self.path = path;
	}
	
	override var description : String {
		return "\(name), \(path)";
	}
}
