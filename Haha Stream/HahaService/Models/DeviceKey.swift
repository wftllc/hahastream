import Foundation

final class DeviceKey: NSObject, FromDictable {
	public var key: String;
	
	static func fromDictionary(_ dict:[String: Any]) -> DeviceKey? {
		guard let key = dict["key"] as? String else { return nil }
		return DeviceKey(key: key);
	}
		
	required public init(key: String) {
		self.key = key;
	}
	
	override var description : String {
		return "\(key)";
	}
}
