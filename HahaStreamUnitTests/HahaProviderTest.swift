import XCTest
import Foundation
import UIKit
import Moya

@testable import Haha_Stream

/*

To make tests work, you MUST have a Config.plist included in the test bundle which has the key "HahaProviderApiKey" and a value of your api key.

*/
class HahaProviderTest: XCTestCase {
	let ApiKeyPath = "HahaProviderApiKey"

	var provider: HahaProvider!;
	
	override func setUp() {
		super.setUp()
		
		self.continueAfterFailure = false;
		let apiKey = loadApiKey()
		XCTAssertNotNil(apiKey)
		self.provider = HahaProvider(apiKey: apiKey);
		XCTAssertNotNil(provider)
	}
	
	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}
	
	func testLoggedIn() {
		let exp = expectation(description: "wait")
		self.provider.getDeviceActivationStatus(success: { status in
			XCTAssert(status.isActivated)
			exp.fulfill()
		}, apiError: { (error) in
			XCTFail("apiError: \(error)")
			exp.fulfill()
		}, networkFailure: { (error) in
			XCTFail("networkFailure: \(error)")
			exp.fulfill()
		});
		waitForExpectations(timeout: 25, handler: nil)
	}
	
	func testNotLoggedIn() {
		let exp = expectation(description: "wait")
		self.provider.apiKey = nil
		self.provider.getDeviceActivationStatus(success: { status in
			XCTAssertFalse(status.isActivated)
			exp.fulfill()
		}, apiError: { (error) in
			XCTFail("apiError: \(error)")
			exp.fulfill()
		}, networkFailure: { (error) in
			XCTFail("networkFailure: \(error)")
			exp.fulfill()
		});
		waitForExpectations(timeout: 25, handler: nil)
	}

	
	func xtestVCSScraping() {
		let exp = expectation(description: "wait")
		var vcses:[VCS] = []
		self.provider.getVCSChannels(success: { (result) in
			vcses = result
			exp.fulfill()
		}, apiError: { (error) in
			XCTFail("apiError: \(error)")
			exp.fulfill()
		}, networkFailure: { (error) in
			XCTFail("networkFailure: \(error)")
			exp.fulfill()
		});
		XCTAssertGreaterThan(vcses.count, 1)
		waitForExpectations(timeout: 25, handler: nil)
	}
	
	//channels are under sports right now
	func xtestChannels() {
		let exp = expectation(description: "wait")
		var channels:[Channel] = []
		provider.getChannels(success: { (channelsRes) in
			channels = channelsRes;
			exp.fulfill()
		}, apiError: { (error) in
			XCTFail("apiError: \(error)")
			exp.fulfill()
		}, networkFailure: { (error) in
			XCTFail("networkFailure: \(error)")
			exp.fulfill()
		})
		waitForExpectations(timeout: 25, handler: nil)
		print(channels)
		XCTAssertGreaterThan(channels.count, 0)
		for channel in channels {
				let exp = expectation(description: "wait")
				provider.getStream(channel: channel, success: { (stream) in
					exp.fulfill()
				}, apiError: { (error) in
					XCTFail("apiError: \(error)")
					exp.fulfill()
				}, networkFailure: { (error) in
					XCTFail("networkFailure: \(error)")
					exp.fulfill()
				})
				waitForExpectations(timeout: 25, handler: nil)
		}
	}
	
	func testContentList() {
		let exp = expectation(description: "wait")
		var items:[ContentItem] = []
		provider.getContentList(success: { (results) in
			items = results;
			exp.fulfill()
		}, apiError: { (error) in
			XCTFail("apiError: \(error)")
			exp.fulfill()
		}, networkFailure: { (error) in
			XCTFail("networkFailure: \(error)")
			exp.fulfill()
		})
		waitForExpectations(timeout: 25, handler: nil)
		print(items)
		var foundGame = false
		var foundChannel = false
		let exp2 = expectation(description: "channel stream")
		for item in items {
			if let channel = item.channel {
				foundChannel = true
				//nba tv seems to be always live
				if channel.title == "NBA TV" {
					provider.getStream(channel: channel, success: { (stream) in
						XCTAssertNotNil(stream)
						exp2.fulfill()
					}, apiError: { (error) in
						XCTFail("apiError: \(error)")
						exp2.fulfill()
					}, networkFailure: { (error) in
						XCTFail("networkFailure: \(error)")
						exp2.fulfill()
					})
				}
			}
			else if let _ = item.game {
				foundGame = true
			}
		}
		XCTAssert(foundGame)
		XCTAssert(foundChannel)
		waitForExpectations(timeout: 25, handler: nil)
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
