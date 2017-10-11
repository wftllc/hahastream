import Foundation

class DeviceActivationStatus: NSObject, FromDictable {
	public var isActivated: Bool;

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		return try self.init(dict: dict)
	}
	
	required public init(dict: [String: Any]) throws {
		self.isActivated = try dict.value("status")
		super.init()
	}
	
	override var description : String {
		return "\(isActivated)";
	}
}
