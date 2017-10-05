import Foundation

extension Dictionary where Key == String {
	public func value(_ keyPath: String) -> Any? {
		
		guard let firstSeparatorIndex = keyPath.index(of: ".") else {
			//at root, just return
			return self[keyPath];
		}
		
		let key = keyPath.prefix(upTo: firstSeparatorIndex)
		let remainder = keyPath.suffix(from: (firstSeparatorIndex))
		
		guard let subdict = self[String(key)] as? [Key: Value] else {
			return nil
		}
		
		return subdict.value(String(remainder))
	}
	
	public func value<T>(_ keyPath: String) throws -> T {
		guard let rawValue = value(keyPath) else {
			throw FromDictableError.keyError(key: "\(keyPath) is empty")
		}
		
		if T.self is URL.Type {
			guard let value = rawValue as? String,
				let url = URL(string: value) else {
					throw FromDictableError.keyError(key: "\(keyPath) is not a \(T.self)")
			}
			return url as! T
		}
		else {
			guard let value = rawValue as? T else {
				throw FromDictableError.keyError(key: "\(keyPath) is not a \(T.self)")
			}
			return value
		}
	}
	/*
	public func dictionary<U>(whereKeyPath keyPath: String, matches: U) throws -> [String: Any]
	where U: Equatable
	{
	guard let lastSeparatorRange = keyPath.range(of: ".", options:[.backwards]) else {
	throw FromDictableError.keyError(key: "\(keyPath) should be two or more levels")
	}
	let key = keyPath.substring(to: lastSeparatorRange.lowerBound)
	let finalKey = keyPath.substring(from: lastSeparatorRange.upperBound)
	let values: [[String: Any]] = try value(keyPath: key)
	guard let dict = (try values.first { dict -> Bool in
	let value: U = try dict.value(keyPath: finalKey)
	return value == matches
	}) else {
	throw FromDictableError.keyError(key: "\(keyPath) matching \(matches) not found")
	}
	return dict
	}
	*/
}

