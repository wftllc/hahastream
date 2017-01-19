import Foundation

protocol FromDictable {
	static func fromDictionary(_ dict:[String: Any]) -> Self?;
}
