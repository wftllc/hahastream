import Foundation

final class DeviceActivation: NSObject, FromDictable {
	public var apiKey: String;
	
	static func fromDictionary(_ dict:[String: Any]) -> DeviceActivation? {
		guard let key = dict["api_key"] as? String else { return nil }
		return DeviceActivation(apiKey: key);
	}
		
	required public init(apiKey: String) {
		self.apiKey = apiKey;
	}
	
	override var description : String {
		return "\(apiKey)";
	}
}
