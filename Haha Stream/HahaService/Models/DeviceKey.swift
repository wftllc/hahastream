import Foundation

class DeviceKey: NSObject, FromDictable {
	public var key: String;
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		let key:String = try dict.value("key")

		return self.init(key: key);
	}
		
	required public init(key: String) {
		self.key = key;
	}
	
	override var description : String {
		return "\(key)";
	}
}
