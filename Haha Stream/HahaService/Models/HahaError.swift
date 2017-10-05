import Foundation
import Moya

final class HahaError: NSObject, FromDictable {
	public var error: String;
	public var underlyingResponse: Response?;
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		throw FromDictableError.otherError(reason: "not implemented")
		//				let key:String = try dict.value(keyPath: "key")
		//		return self.init(key: key);
	}

	static func fromDictionary(_ dict:[String: Any]) -> HahaError? {
		guard let error = dict["error"] as? String else { return nil }
		return HahaError(error: error);
	}
		
	required public init(error: String) {
		self.error = error;
	}
	
	override var description : String {
		return "\(error)";
	}
}
