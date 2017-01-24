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
	
	
	func getNowPlaying(
		success successCallback: @escaping ([NowPlayingItem]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		//get all sports, then get all games for today and the next/prev day if it is within 4 hrs
		self.getSports(success: { (sports) in
			DispatchQueue.global().async {
				var allGames:[Game] = []
				var allChannels:[Channel] = []
				let semaphore = DispatchSemaphore(value: 0);
				for sport in sports {
					var date = Date();
					//if 4 hours earlier is yesterday, let's get those games instead
					if( Calendar.current.isDateInYesterday(Date(timeIntervalSinceNow:-4*60*60)) ) {
						date.addTimeInterval(-4*60*60);
					}
					self.getGames(sport: sport, date: date, success: { (games) in
						allGames.append(contentsOf: games);
						semaphore.signal()
					}, apiError: { (error) in
						semaphore.signal()
					}, networkFailure: { (error) in
						semaphore.signal()
					});
				}
				self.getChannels(sports: sports, success: { (channels) in
					allChannels.append(contentsOf:channels)
					semaphore.signal()
				}, apiError: { (error) in
					semaphore.signal()
				}, networkFailure: { (error) in
					semaphore.signal()
				});
				for _ in 1...sports.count+1 {
					semaphore.wait()
				}
				
				let results = self.processNowPlaying(games: allGames, channels: allChannels)
				DispatchQueue.main.async {
					successCallback(results)
				}
			}
		}, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	func processNowPlaying(games: [Game], channels: [Channel]) -> [NowPlayingItem] {
		var results: [NowPlayingItem] = [];

		//this goes like: current games => channels => upcoming games
		let channels = channels.filter{ $0.active }.sorted{ $0.title < $1.title }
		
		//let's get all the "ready" and "active" games, meaning
		//games that are ready and <4 hrs old
		let readyGames = games.filter{ $0.active && $0.sport.name.lowercased() != "vcs" }
		let upcomingGames = games.filter{ $0.upcoming && $0.sport.name.lowercased() != "vcs" }
		
		results.append(contentsOf: readyGames.sorted(by: gameSort).map{ NowPlayingItem(game: $0) })
		results.append(contentsOf: channels.map { NowPlayingItem(channel: $0) })
		results.append(contentsOf: upcomingGames.sorted(by: gameSort).map{ NowPlayingItem(game: $0) })
		
		return results;
	}
	
	func gameSort(_ a: Game, _ b: Game) -> Bool {
		if a.startDate != b.startDate {
			return a.startDate < b.startDate
		}
		if a.sport.name != b.sport.name {
			return a.sport.name < b.sport.name;
		}
		if a.title < b.title {
			return true;
		}
		
		return false;
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
