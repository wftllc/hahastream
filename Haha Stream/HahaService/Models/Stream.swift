import Foundation

final class Stream: NSObject, FromDictable {
	public var id: String;
	public var title: String;

	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }

		let id:String = try dict.value("id")
		let title: String = try dict.value("title")
		return self.init(id: id, title: title);
	}
	
	required public init(id: String, title: String) {
		self.id = id;
		self.title = title;
	}
	
	override var description : String {
		return "\(title): \(id)";
	}
}

