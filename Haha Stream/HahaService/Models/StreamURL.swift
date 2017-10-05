import Foundation

class StreamURL: NSObject, FromDictable {
	public var url: URL

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }

		let url: URL = try dict.value("url")
		return self.init(url: url);
	}
	
	required public init(url: URL) {
		self.url = url
	}
	
	override var description : String {
		return "\(url)";
	}
}

