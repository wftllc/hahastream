import UIKit

class AppProvider: NSObject {
	static var ApiKeyKey = "hehe_api_key";

	class var apiKey: String? {
		get {
			return UserDefaults.standard.string(forKey: ApiKeyKey)
		}
		set {
			UserDefaults.standard.set(newValue, forKey: ApiKeyKey);
		}
	}
}
