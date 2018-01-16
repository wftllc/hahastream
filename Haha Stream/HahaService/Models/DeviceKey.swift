import Foundation

class DeviceKey: NSObject, FromDictable {
	public var key: String;
	public var dict: [String: Any]
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		let key:String = try dict.value("key")

		return self.init(key: key, dict: dict);
	}
		
	required public init(key: String, dict: [String: Any]) {
		self.key = key;
		self.dict = dict
	}
	
	override var description : String {
		return "\(key); \(dict)";
	}
}
