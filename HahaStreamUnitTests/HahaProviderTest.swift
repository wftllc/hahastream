import XCTest
import Foundation
import UIKit

@testable import Haha_Stream

/*

To make tests work, you MUST have a Config.plist included in the test bundle which has the key "HahaProviderApiKey" and a value of your api key.

*/
class HahaProviderTest: XCTestCase {
	let ApiKeyPath = "HahaProviderApiKey"
	var provider: HahaProvider!;
	override func setUp() {
		super.setUp()
		let apiKey = loadApiKey()
		XCTAssertNotNil(apiKey)
		self.provider = HahaProvider(apiKey: apiKey);
		XCTAssertNotNil(provider)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testSportsGamesStreamFetchingFlow() {
		var exp = expectation(description: "wait")
		var sports: [Sport] = []
		provider.getSports(success: { (sportsRes) in
			sports = sportsRes;
			exp.fulfill()
		}, apiError: { (error) in
			XCTFail("apiError: \(error)")
		}, networkFailure: { (error) in
			XCTFail("networkFailure: \(error)")
		})
		waitForExpectations(timeout: 25, handler: nil)
		
		print(sports)
		XCTAssertGreaterThan(sports.count, 0)

		for sport in sports {
			//just make sure the failure callbacks don't get hit.
			exp = expectation(description: "fetch \(sport.name) games" )
			print(sport)
			provider.getGames(sport: sport, date: nil, success: { (games) in
				print(games)
				exp.fulfill()
			}, apiError: { (error) in
				XCTFail("apiError: \(error)")
			}, networkFailure: { (error) in
				XCTFail("networkFailure: \(error)")
			})
			waitForExpectations(timeout: 25, handler: nil)
		}

	}
	
	func loadApiKey() -> String? {
		let bundle = Bundle(for: HahaProviderTest.self);
		guard let path = bundle.path(forResource: "Config", ofType: "plist") else { return nil }
		let dict = NSDictionary(contentsOfFile: path);
		return dict?.value(forKeyPath: ApiKeyPath) as? String;
	}
	
}
