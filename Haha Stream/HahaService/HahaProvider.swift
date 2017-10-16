import Foundation
import Moya
import Result

class HahaProvider:NSObject {
	var provider: MoyaProvider<HahaService>!;
	public var apiKey: String?;
	
	init(apiKey: String?) {
		self.apiKey = apiKey;
		super.init();
		setupProvider();
	}
	
	
	func url(_ route: TargetType) -> String {
		return route.baseURL.appendingPathComponent(route.path).absoluteString
	}
	
	func setupProvider() {
		let endpointClosure = { (target: HahaService) -> Endpoint<HahaService> in
			var endpoint = MoyaProvider.defaultEndpointMapping(for: target);
			//			endpoint.url = self.url(target)
			//			var endpoint: Endpoint<HahaService> = Endpoint<HahaService>(
			//				url: self.url(target),
			//				sampleResponseClosure: {.networkResponse(200, target.sampleData)},
			//				method: target.method,
			//				task: target.task
			//			);
			
			if let apiKeyForced = self.apiKey {
				endpoint = endpoint.adding(newHTTPHeaderFields: ["ApiKey": apiKeyForced]);
			}
			return endpoint
		}
		
		self.provider = MoyaProvider<HahaService>(endpointClosure: endpointClosure);
		
	}
	
	//MARK: - Device activation
	
	func getDeviceRegistrationKey(
		success successCallback: @escaping (DeviceKey?) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		self.getOne(endpoint: .getDeviceKey(deviceUUID: UIDevice.current.identifierForVendor!.uuidString), success: successCallback, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	func deactivateDevice(
		success: @escaping () -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		self.requestOne(endpoint: .deactivateDevice(), success: { (_) in
			success()
		}, apiError: apiError, networkFailure: networkFailure)
	}
	
	func activateDevice(
		deviceKey: DeviceKey,
		success successCallback: @escaping (DeviceActivation) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		self.getOne(endpoint: .activateDevice(deviceKey: deviceKey.key),
		            success: successCallback,
		            apiError: errorCallback,
		            networkFailure: failureCallback);
	}
	
	func getDeviceActivationStatus(
		success: @escaping (DeviceActivationStatus) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		self.getOne(endpoint: .getDeviceActivationStatus(), success: success, apiError: apiError, networkFailure: networkFailure)
	}
	
	//MARK: - Services/Sports
	
	func getSports(
		success successCallback: @escaping ([Sport]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		
		self.get(endpoint: .getSports, success: successCallback, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	//MARK: - Channels
	
	func getChannels(
		sports: [Sport],
		success successCallback: @escaping ([Channel]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		DispatchQueue.global().async {
			var allChannels:[Channel] = []
			let semaphore = DispatchSemaphore(value: 0);
			for sport in sports {
				self.get(endpoint: HahaService.getChannels(sport: sport.name.lowercased()),
				         success: { (channels: [Channel]) in
									//									for channel in channels {
									//										channel.sport = sport;
									//									}
									allChannels.append(contentsOf: channels);
									semaphore.signal()
				}, apiError: { (error) in
					semaphore.signal()
				}, networkFailure: { (error) in
					semaphore.signal()
				});
			}
			for _ in 1...sports.count {
				semaphore.wait()
			}
			DispatchQueue.main.async {
				successCallback(allChannels)
			}
		}
	}
	func getChannels(
		success successCallback: @escaping ([Channel]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		self.getSports(success: { (sports) in
			self.getChannels(sports: sports, success: successCallback, apiError: errorCallback, networkFailure: failureCallback);
		}, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	
	//MARK: - Content Lists
	
	func getContentList(
		success successCallback: @escaping (ContentList) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		//get all sports, then get all games for today and the next/prev day if it is within 4 hrs
		self.getSports(success: { (sports) in
			DispatchQueue.global().async {
				let allContentList = ContentList()
				let semaphore = DispatchSemaphore(value: 0);
				for sport in sports {
					self.getContentList(sport: sport, date: nil, success: { (contentList) in
						allContentList.merge(withContentList: contentList)
						semaphore.signal()
					}, apiError: { (error) in
						semaphore.signal()
					}, networkFailure: { (error) in
						semaphore.signal()
					});
				}
				for _ in 1...sports.count {
					semaphore.wait()
				}
				
				DispatchQueue.main.async {
					successCallback(allContentList)
				}
			}
		}, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	func getContentList(
		sport: Sport,
		date: Date?,
		success: @escaping (ContentList) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		let endpoint: HahaService;
		
		//		let date4hoursAgo = Date(timeIntervalSinceNow:-4*60*60)
		//		let date = date ?? (Calendar.current.isDateInYesterday(date4hoursAgo) ? date4hoursAgo : Date())
		
		if let date = date {
			let calendar = Calendar.current;
			let targetComponents = Set<Calendar.Component>(arrayLiteral: .year, .month, .day);
			let dateComponents = calendar.dateComponents(targetComponents, from: date);
			endpoint = HahaService.getGames(sport: sport.name.lowercased(), year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
		}
		else {
			endpoint = HahaService.getGamesNoDate(sport: sport.name.lowercased())
		}
		
		self.get(endpoint: endpoint,
		         success: { (items: [ContentItem]) in
							items.forEach({ (item) in
								if let channel = item.channel {
									channel.sport = sport //add sport manually
								}
							})
							let contentList = ContentList.contentList(bySortingItems: items)
							contentList.date = date
							success(contentList)
		},
		         apiError: apiError,
		         networkFailure: networkFailure);
	}

	
	func getNFLContentList(
		week: NFLWeek?,
		success: @escaping (ContentList) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		let endpoint: HahaService;
		let sport = Sport(name: "NFL", path: "/services/nfl")
		//		let date4hoursAgo = Date(timeIntervalSinceNow:-4*60*60)
		//		let date = date ?? (Calendar.current.isDateInYesterday(date4hoursAgo) ? date4hoursAgo : Date())
		
		if let week = week {
			endpoint = HahaService.getNFLGames(year: week.year, seasonType: week.type.rawValue, week: week.week)
		}
		else {
			endpoint = HahaService.getGamesNoDate(sport: "nfl")
		}
		
		self.get(endpoint: endpoint,
		         success: { (items: [ContentItem]) in
							items.forEach({ (item) in
								if let channel = item.channel {
									channel.sport = sport //add sport manually
								}
							})
							let contentList = ContentList.contentList(bySortingItems: items)
							contentList.nflWeek = week
							success(contentList)
		},
		         apiError: apiError,
		         networkFailure: networkFailure);
	}

	
	//MARK: - Streams
	
	func getStreams(
		game: Game,
		success successCallback: @escaping ([Stream]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		getStreams(sportName: game.sport.name.lowercased(), gameUUID: game.uuid, success: successCallback, apiError: errorCallback, networkFailure: failureCallback)
	}
	
	func getStream(
		channel: Channel,
		success: @escaping (Stream) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint = HahaService.getChannelStreams(channelId: channel.uuid)
		self.getOne(endpoint: endpoint, success: { (streamMeta: StreamMeta?) in
			success(streamMeta!.streams.first!)
		},
		            apiError: apiError,
		            networkFailure: networkFailure);
	}
	
	func getStreams(
		sportName: String,
		gameUUID: String,
		success: @escaping ([Stream]) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint = HahaService.getStreams(sport: sportName, gameId: gameUUID);
		self.getOne(endpoint: endpoint, success: { (streamMeta: StreamMeta?) in
			success(streamMeta!.streams)
		},
		            apiError: apiError,
		            networkFailure: networkFailure);
	}
	
	func getVCSStreams(
		vcs: VCS,
		success successCallback: @escaping ([Stream]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		//TODO: implement
		//		let endpoint = HahaService.getStreams(sport: "vcs", gameUUID: vcs.uuid);
		//
		//		self.get(endpoint: endpoint,
		//		         success: successCallback,
		//		         apiError: errorCallback,
		//		         networkFailure: failureCallback);
	}
	
	func getStreamURL(
		forStream stream: Stream,
		inGame game: Game,
		success: @escaping (StreamURL) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		let endpoint = HahaService.getStreamURLForItem(itemId: game.uuid,
		                                               streamId: stream.id,
		                                               sport: game.sport.name.lowercased());
		
		self.getOne(endpoint: endpoint, success: success, apiError: apiError, networkFailure: networkFailure);
	}
	
	func getStreamURL(
		forStream stream: Stream,
		inChannel channel: Channel,
		success: @escaping (StreamURL) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		let endpoint = HahaService.getStreamURLForItem(itemId: channel.uuid,
		                                               streamId: stream.id,
		                                               sport: nil);
		
		self.getOne(endpoint: endpoint, success: success, apiError: apiError, networkFailure: networkFailure);
	}
		
	func getVCSChannels(
		success successCallback: @escaping ([VCS]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		var results:[VCS] = []
		
		results.sort { (a, b) -> Bool in
			return a.name < b.name;
		}
		successCallback(results);
	}
	
	//MARK: - Game/Content Items
	
	func getGame(
		sportName: String,
		gameUUID: String,
		success successCallback: @escaping (Game?) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		let endpoint = HahaService.getGame(sport: sportName.lowercased(), uuid: gameUUID)
		self.getOne(endpoint: endpoint,
		            success: successCallback,
		            apiError: errorCallback,
		            networkFailure: failureCallback);
	}
	
	//MARK: - helpers
	
	
	func get<T:FromDictable>(endpoint: HahaService,
	                         success: @escaping ([T]) -> Void,
	                         apiError errorCallback: @escaping (Any) -> Void,
	                         networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		request(endpoint: endpoint,
		        success: { dictionaries in
							var array: [T] = [];
							for dict in dictionaries {
								do {
									let object = try T.fromDictionary(dict)
									array.append(object)
								}
								catch {
									print("parse error; \(T.self) \(error)")
								}
							}
							success(array);
		},
		        apiError: errorCallback,
		        networkFailure: failureCallback
		);
	}
	
	func getOne<T:FromDictable>(endpoint: HahaService,
	                            success: @escaping (T) -> Void,
	                            apiError: @escaping (Any) -> Void,
	                            networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		requestOne(endpoint: endpoint,
		           success: { dict in
								
								do {
									let object = try T.fromDictionary(dict)
									success(object)
								}
								catch {
									apiError(error)
								}
		},
		           apiError: apiError,
		           networkFailure: failureCallback
		);
	}
	
	
	func request(
		endpoint: HahaService,
		success successCallback: @escaping ([[String: AnyObject]]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		self.provider.request(endpoint) { result in
			switch(result) {
			case let .success(moyaResponse):
				do {
					let response = try moyaResponse.filterSuccessfulStatusCodes();
					let json = try response.mapJSON();
					guard let array = json as? [[String: AnyObject]] else {
						throw MoyaError.jsonMapping(response);
					}
					successCallback(array);
				}
				catch {
					let originalError = error;
					do {
						let json = try moyaResponse.mapJSON()
						let dict = json as! [String: AnyObject]
						if let hahaError = HahaError.fromDictionary(dict)
						{
							hahaError.underlyingResponse = moyaResponse;
							errorCallback(hahaError);
						}
						else {
							errorCallback(originalError)
						}
					}
					catch {
						errorCallback(originalError)
					}
				}
			case let .failure(error):
				failureCallback(error)
			}
		}
	}
	
	func requestOne(
		endpoint: HahaService,
		success successCallback: @escaping ([String: AnyObject]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		self.provider.request(endpoint) { result in
			switch(result) {
			case let .success(moyaResponse):
				do {
					let response = try moyaResponse.filterSuccessfulStatusCodes();
					let json = try response.mapJSON();
					guard let dict = json as? [String: AnyObject] else {
						throw MoyaError.jsonMapping(response);
					}
					successCallback(dict);
				}
				catch {
					let originalError = error;
					do {
						let json = try moyaResponse.mapJSON()
						let dict = json as! [String: AnyObject]
						let hahaError = HahaError.fromDictionary(dict)!
						hahaError.underlyingResponse = moyaResponse;
						errorCallback(hahaError);
					}
					catch {
						errorCallback(originalError)
					}
				}
			case let .failure(error):
				failureCallback(error)
			}
		}
	}
}

extension String {
	func matchingStrings(regex: String) -> [[String]] {
		guard let regex = try? NSRegularExpression(pattern: regex, options: [.dotMatchesLineSeparators]) else { return [] }
		let nsString = self as NSString
		let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, nsString.length))
		return results.map { result in
			(0..<result.numberOfRanges).map { result.range(at: $0).location != NSNotFound
				? nsString.substring(with: result.range(at: $0))
				: ""
			}
		}
	}
}
