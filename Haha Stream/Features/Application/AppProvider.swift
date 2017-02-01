import UIKit

class AppProvider: NSObject {
	private static let SuiteName = "group.com.wftllc.haha-stream.shared"
	private static let ApiKeyKey = "hehe_api_key";

	class var apiKey: String? {
		get {
			let userDefaults = UserDefaults(suiteName: SuiteName);
			return userDefaults?.string(forKey: ApiKeyKey)
		}
		set {
			let userDefaults = UserDefaults(suiteName: SuiteName);
			userDefaults?.set(newValue, forKey: ApiKeyKey);
		}
	}
}
