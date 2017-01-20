import Foundation

final class Sport: NSObject, FromDictable {
	public var name: String;
	public var path: String;
	public var status: Bool;
	
	static func fromDictionary(_ dict:[String: Any]) -> Sport? {
		print(dict)
		guard let name = dict["name"] as? String else { return nil }
		guard let path = dict["path"] as? String else { return nil }
		guard let status = dict["status"] as? Bool else { return nil }
		return Sport(name: name, path: path, status: status);
	}
		
	required public init(name: String, path: String, status: Bool) {
		self.name = name;
		self.path = path;
		self.status = status;
	}
	
	override var description : String {
		return "\(name), \(path), \(status)";
	}
}
