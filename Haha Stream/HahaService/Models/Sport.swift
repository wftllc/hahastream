import Foundation

final class Sport: NSObject, FromDictable {
	public var name: String;
	public var path: String;
	
	static func fromDictionary(_ dict:[String: Any]) -> Sport? {
		guard let name = dict["name"] as? String else { return nil }
		guard let path = dict["collection_endpoint"] as? String else { return nil }
		return Sport(name: name, path: path);
	}
		
	required public init(name: String, path: String) {
		self.name = name;
		self.path = path;
	}
	
	override var description : String {
		return "\(name), \(path)";
	}
}
