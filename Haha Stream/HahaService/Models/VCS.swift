import Foundation

final class VCS: NSObject, FromDictable {
	public var uuid: String;
	public var name: String;
	public var imageURL: URL {
		return URL(string: "http://logos.hehestreams.xyz/image/vue_channels/\(uuid).png")!
	}

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
//		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		throw FromDictableError.otherError(reason: "not implemented")
//				let key:String = try dict.value(keyPath: "key")
//		return self.init(key: key);
	}

	static func fromDictionary(_ dict:[String: Any]) -> VCS? {
		guard let name = dict["name"] as? String else { return nil }
		guard let uuid = dict["uuid"] as? String else { return nil }
		return VCS(name: name, uuid: uuid);
	}
		
	required public init(name: String, uuid: String) {
		self.name = name;
		self.uuid = uuid;
	}
	
	override var description : String {
		return "\(name), \(uuid)";
	}
}
