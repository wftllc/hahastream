import UIKit

class AppProvider: NSObject {
	public enum AppTestingMode: String {
		case none
		case unitTests
		case uiTests
	}
	public static let AppIsInUnitTestModeKey = "COM_WFTLLC_APP_IS_IN_UNIT_TEST_MODE"
	private static let AppGroupName = "group.com.wftllc.haha-stream.shared"
	private static let ApiKeyKey = "hehe_api_key";

	let isInUnitTestMode: Bool
	
	override init() {
		let env = ProcessInfo.processInfo.environment
		let value = env[type(of: self).AppIsInUnitTestModeKey] ?? ""
		
		self.isInUnitTestMode = Bool(value) ?? false
		super.init()
	}
	
	
	var isLoggedIn: Bool {
		return self.apiKey != nil
	}
	
	var apiKey: String? {
		get {
			let userDefaults = UserDefaults(suiteName: type(of: self).AppGroupName);
			return userDefaults?.string(forKey: type(of: self).ApiKeyKey)
		}
		set {
			let userDefaults = UserDefaults(suiteName: type(of: self).AppGroupName);
			userDefaults?.set(newValue, forKey: type(of: self).ApiKeyKey);
		}
	}
}
