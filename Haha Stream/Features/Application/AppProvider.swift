import UIKit

class AppProvider: NSObject {
	private static let AppGroupName = "group.com.wftllc.haha-stream.shared"
	private static let ApiKeyKey = "hehe_api_key";

	class var apiKey: String? {
		get {
			let userDefaults = UserDefaults(suiteName: AppGroupName);
			return userDefaults?.string(forKey: ApiKeyKey)
		}
		set {
			let userDefaults = UserDefaults(suiteName: AppGroupName);
			userDefaults?.set(newValue, forKey: ApiKeyKey);
		}
	}
}
