import Foundation
import Moya

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
			var endpoint: Endpoint<HahaService> = Endpoint<HahaService>(
				url: self.url(target),
				sampleResponseClosure: {.networkResponse(200, target.sampleData)},
				method: target.method,
				parameters: target.parameters
			);
			
			if let apiKeyForced = self.apiKey {
				endpoint = endpoint.adding(httpHeaderFields: ["ApiKey": apiKeyForced]);
			}
			return endpoint
		}
		
		self.provider = MoyaProvider<HahaService>(endpointClosure: endpointClosure);
		
	}

	func getSports(
		success successCallback: @escaping ([Sport]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		
		self.get(endpoint: .getSports, success: successCallback, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	func getGames(
		sport: Sport,
		date: Date?,
		success successCallback: @escaping ([Game]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint: HahaService;
		if let forcedDate = date {
			let calendar = Calendar.current;
			let targetComponents = Set<Calendar.Component>(arrayLiteral: .year, .month, .day);
			let dateComponents = calendar.dateComponents(targetComponents, from: forcedDate);
			
			endpoint = HahaService.getGames(sport: sport.name.lowercased(),
			                                year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
		}
		else {
			endpoint = HahaService.getGamesNoDate(sport: sport.name.lowercased())
		}
		
		self.get(endpoint: endpoint,
		         success: { (games: [Game]) in
							for game in games {
								game.sport = sport;
							}
							successCallback(games);
		},
		         apiError: errorCallback,
		         networkFailure: failureCallback);
	}
	
	func getChannels(
		success successCallback: @escaping ([Channel]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		self.getSports(success: { (sports) in
			DispatchQueue.global().async {
				var allChannels:[Channel] = []
				let semaphore = DispatchSemaphore(value: 0);
				for sport in sports {
					self.get(endpoint: HahaService.getChannels(sport: sport.name.lowercased()),
					         success: { (channels: [Channel]) in
										for channel in channels {
											channel.sport = sport;
										}
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
		}, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	
	//TODO: combine all nowPlaying calls into one call
	
	func getCurrentGames(
		success successCallback: @escaping ([Game]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		
		
		self.getSports(success: { (sports) in
			DispatchQueue.global().async {
				var allGames:[Game] = []
				let semaphore = DispatchSemaphore(value: 0);
				for sport in sports {
					self.getGames(sport: sport, date: nil, success: { (games) in
						allGames.append(contentsOf: games);
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
					successCallback(allGames)
				}
			}
		}, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	func getStreams(
		sport: Sport,
		game: Game,
		success successCallback: @escaping ([Stream]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint = HahaService.getStreams(sport: sport.name.lowercased(),
		                                      gameUUID: game.uuid);
		
		self.get(endpoint: endpoint,
		         success: successCallback,
		         apiError: errorCallback,
		         networkFailure: failureCallback);
	}
	
	func getStream(
		channel: Channel,
		success successCallback: @escaping (Stream?) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint = HahaService.getStreamForChannel(sport: channel.sport!.name.lowercased(), channelId: channel.identifier);
		
		self.getOne(endpoint: endpoint,
		         success: successCallback,
		         apiError: errorCallback,
		         networkFailure: failureCallback);
	}
	
	
	func get<T:FromDictable>(endpoint: HahaService,
	         success successCallback: @escaping ([T]) -> Void,
	         apiError errorCallback: @escaping (Any) -> Void,
	         networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		request(endpoint: endpoint,
		        success: { dictionaries in
							var array: [T] = [];
							for dict in dictionaries {
								guard let object = T.fromDictionary(dict) else {
									print("couldn't parse",dict);
									continue;
								}
								array.append(object)
							}
							successCallback(array);
		},
		        apiError: errorCallback,
		        networkFailure: failureCallback
		);
	}
	
	func getOne<T:FromDictable>(endpoint: HahaService,
	            success successCallback: @escaping (T?) -> Void,
	            apiError errorCallback: @escaping (Any) -> Void,
	            networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		requestOne(endpoint: endpoint,
		           success: { dict in
								
								if let object = T.fromDictionary(dict as [String: AnyObject]) {
									successCallback(object);
								}
								else {
									print("couldn't parse \(dict)");
									successCallback(nil);
								}
		},
		           apiError: errorCallback,
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
	}}
