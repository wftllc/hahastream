import Foundation

protocol FromDictable {
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self;
}

enum FromDictableError: Error {
	case otherError(reason: String)
	case keyError(key: String)
	var localizedDescription: String {
		switch self {
		case .otherError(let string):
			return "Other Error: \(string)"
		case .keyError(let string):
			return "Key Error: \(string)"
		}
	}
}

