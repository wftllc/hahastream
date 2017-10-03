import Foundation

final class Stream: NSObject, FromDictable {
	public var id: String!;
	public var title: String!;
	public var url: URL!
	
	static func fromDictionary(_ dict:[String: Any]) -> Stream? {
		let id = dict["id"] as? String
		let title = dict["title"] as? String
		var url: URL? = nil
		if let s = dict["url"] as? String {
			url = URL(string: s)
		}
		return Stream(id: id, title: title, url: url);
	}
	
	required public init(id: String?, title: String?, url: URL?) {
		self.id = id;
		self.title = title;
		self.url = url
	}
	
	override var description : String {
		return "\(title): \(id)";
	}
}

