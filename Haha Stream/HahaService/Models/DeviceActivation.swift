import Foundation

final class DeviceActivation: NSObject, FromDictable {
	public var apiKey: String;

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		return try self.init(dict: dict)
	}
	
	required public init(dict: [String: Any]?) throws {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		self.apiKey = try dict.value("api_key");
	}
	
	override var description : String {
		return "\(apiKey)";
	}
}
