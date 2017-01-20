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
		         success: successCallback,
		         apiError: errorCallback,
		         networkFailure: failureCallback);
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
					//					for dictMaybe in array {
					//						guard let dict = dictMaybe as? [String: AnyObject] else {
					//							throw SimpleError.error;
					//						}
					//						guard let sport = Sport.fromDictionary(dict) else {
					//							print("couldn't parse",dict);
					//							continue;
					//						}
					//						print(sport);
					//					}
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
}
