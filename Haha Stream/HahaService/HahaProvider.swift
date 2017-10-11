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
	
	func getSports(
		success successCallback: @escaping ([Sport]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		
		self.get(endpoint: .getSports, success: successCallback, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	func getNowPlaying(
		sport: Sport,
		date: Date,
		success: @escaping ([NowPlayingItem]) -> Void,
		apiError: @escaping (Any) -> Void,
		networkFailure: @escaping (MoyaError) -> Void
		)
	{
		let endpoint: HahaService;
		let calendar = Calendar.current;
		let targetComponents = Set<Calendar.Component>(arrayLiteral: .year, .month, .day);
		let dateComponents = calendar.dateComponents(targetComponents, from: date);
		
		endpoint = HahaService.getNowPlaying(sport: sport.name.lowercased(), year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
		
		self.get(endpoint: endpoint,
		         success: success,
		         apiError: apiError,
		         networkFailure: networkFailure);
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
	
	
	func getNowPlaying(
		success successCallback: @escaping ([[NowPlayingItem]]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		) {
		//get all sports, then get all games for today and the next/prev day if it is within 4 hrs
		self.getSports(success: { (sports) in
			DispatchQueue.global().async {
				var allItems:[NowPlayingItem] = []
				let semaphore = DispatchSemaphore(value: 0);
				var date = Date();
				//if 4 hours earlier is yesterday, let's get those games instead
				if( Calendar.current.isDateInYesterday(Date(timeIntervalSinceNow:-4*60*60)) ) {
					date.addTimeInterval(-4*60*60);
				}
				for sport in sports {
					self.getNowPlaying(sport: sport, date: date, success: { (items) in
						items.forEach({ (item) in
							if let channel = item.channel {
								channel.sport = sport //add sport manually
							}
						})
						allItems.append(contentsOf: items)
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
				
				let sections = self.sortNowPlayingItemsIntoSections(items: allItems)
				DispatchQueue.main.async {
					successCallback(sections)
				}
			}
		}, apiError: errorCallback, networkFailure: failureCallback);
	}
	
	func sortNowPlayingItemsIntoSections(items: [NowPlayingItem]) -> [[NowPlayingItem]] {
		var ready: [NowPlayingItem] = []
		var channels: [NowPlayingItem] = []
		var upcoming: [NowPlayingItem] = []
		
		items.filter{ !($0.game?.ended == .some(true)) } .forEach { (item) in
			if let game = item.game {
				if game.ready {
					ready.append(item)
				}
				else {
					upcoming.append(item)
				}
			}
			else if let _ = item.channel {
				channels.append(item)
			}
		}
		//this goes like: current games => channels => upcoming games
		
		ready = ready.sorted(by: gameSort)
		upcoming = upcoming.sorted(by: gameSort)
		channels = channels.sorted(by: channelSort)
		
		return [ready, channels, upcoming];
	}
	
	func gameSort(_ a: NowPlayingItem, _ b: NowPlayingItem) -> Bool {
		guard let a = a.game, let b = b.game else {
			return false
		}
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
	
	func channelSort(_ a: NowPlayingItem, _ b: NowPlayingItem) -> Bool {
		guard let a = a.channel, let b = b.channel else {
			return false
		}
		return a.title < b.title
	}
	
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
		success successCallback: @escaping (Stream) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint = HahaService.getChannelStreamMetas(channelUUID: channel.uuid)
		self.getOne(endpoint: endpoint, success: { (streamMeta: StreamMeta?) in
			successCallback(streamMeta!.streams.first!)
		},
		            apiError: errorCallback,
		            networkFailure: failureCallback);
	}

	func getStreams(
		sportName: String,
		gameUUID: String,
		success successCallback: @escaping ([Stream]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint = HahaService.getStreamMetas(sport: sportName, gameUUID: gameUUID);
		self.getOne(endpoint: endpoint, success: { (streamMeta: StreamMeta?) in
			successCallback(streamMeta!.streams)
		},
		            apiError: errorCallback,
		            networkFailure: failureCallback);
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
	
	func getVCSChannels(
		success successCallback: @escaping ([VCS]) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		var results:[VCS] = []
		results.append(VCS(name: "Fox Sports South BGPP", uuid: "a1e7ab0d31487ce2"));
		results.append(VCS(name: "Telemundo Phi Wwsidt2", uuid: "966a5434388300bf"));
		results.append(VCS(name: "Nbc Kntvdt2 Sfo", uuid: "d9005303915167db"));
		results.append(VCS(name: "Fox Phi Wtxfdt2", uuid: "dbc6af5b98fbc093"));
		results.append(VCS(name: "Cbs Phi Kywdt2", uuid: "93a83084ddc04410"));
		results.append(VCS(name: "Fox Sports Carolinas (North Carolina)", uuid: "5e88bc1db5679cac"));
		results.append(VCS(name: "Disney XD (Pacific Feed)", uuid: "fc6ec8cefb6e32b3"));
		results.append(VCS(name: "CBS 62 Detroit", uuid: "2641af88adbdab8a"));
		results.append(VCS(name: "Tvland (Pacific Feed)", uuid: "b3a4d7d2354591bd"));
		results.append(VCS(name: "YES Network", uuid: "84efa9f85870e5ed"));
		results.append(VCS(name: "Discovery Channel (Spanish)", uuid: "31af9aa05a34d7b7"));
		results.append(VCS(name: "Telemundo Fresno", uuid: "f62530a22ebbc42e"));
		results.append(VCS(name: "Fox Sports San Diego", uuid: "00a3d8dc6b2bebca"));
		results.append(VCS(name: "Fox 5 Atlanta", uuid: "35b9af4f06585599"));
		results.append(VCS(name: "CBS 12 West Palm Beach", uuid: "38234188527a81ec"));
		results.append(VCS(name: "Fox Sports Southwest Houston Plus", uuid: "ad36ede3bd045b17"));
		results.append(VCS(name: "NBC 4 Washington D.C.", uuid: "0039c021a78ff022"));
		results.append(VCS(name: "BeIn Sports (Spanish)", uuid: "2292cd39008cb018"));
		results.append(VCS(name: "CBS 2 Pittsburgh", uuid: "4496a01717e9bbec"));
		results.append(VCS(name: "Starz Cinema", uuid: "a02c40f0ed331393"));
		results.append(VCS(name: "My9 New York", uuid: "7efb1d56c2459c10"));
		results.append(VCS(name: "Fx (Pacific Feed)", uuid: "1660f4ece85a70d4"));
		results.append(VCS(name: "HGTV (Pacific Feed)", uuid: "78cb33584022f158"));
		results.append(VCS(name: "ABC 30 Fresno", uuid: "074ebe575559581f"));
		results.append(VCS(name: "Fox Foxsportscd Sad", uuid: "d70bc540b5867e2b"));
		results.append(VCS(name: "Telemundo 40 Rio Grande City", uuid: "e055dbbef8e0d70d"));
		results.append(VCS(name: "CBS 2 Los Angeles", uuid: "8048c8daa2e78758"));
		results.append(VCS(name: "My45 Phoenix", uuid: "5d56ad0c6490575f"));
		results.append(VCS(name: "Fox Sports North Florida", uuid: "d2073e6b4e84ce64"));
		results.append(VCS(name: "CBS 4 Boston", uuid: "d02555c3170a5490"));
		results.append(VCS(name: "Nbc Olympics Soc", uuid: "75631f01a762c71b"));
		results.append(VCS(name: "Nbc Knbcdt2 Lax", uuid: "6101d63af61178e7"));
		results.append(VCS(name: "Fox Sports Midwest St. Louis", uuid: "5f84f52d69448386"));
		results.append(VCS(name: "Movies! New York", uuid: "ae7f49260fea3bcb"));
		results.append(VCS(name: "New England Sports Network Plus", uuid: "e03b7adf3d4026ad"));
		results.append(VCS(name: "KTVU Plus", uuid: "8ada20d0d3d209b0"));
		results.append(VCS(name: "Fox Sports Ohio", uuid: "aac0ea14faf28daf"));
		results.append(VCS(name: "CBS 21 Harrisburg", uuid: "8d2779dea20306fc"));
		results.append(VCS(name: "ABC 7 Los Angeles", uuid: "399940473d06b566"));
		results.append(VCS(name: "Telemundo Denver", uuid: "eb01516490371f81"));
		results.append(VCS(name: "Fox Sports Arizona", uuid: "17042fa05ddd2f0c"));
		results.append(VCS(name: "CBS 5 San Francisco", uuid: "3794ce9503050694"));
		results.append(VCS(name: "Fox Sports Indiana", uuid: "c137a40159c76734"));
		results.append(VCS(name: "CSN Boston", uuid: "bbeb4a6d59f3dc27"));
		results.append(VCS(name: "Cine Sony Television (Spanish)", uuid: "df92f9e35cee1e6a"));
		results.append(VCS(name: "Fox Sports Detroit Plus", uuid: "ea7a41bb743af51d"));
		results.append(VCS(name: "CBS 3 Hartford/New Haven", uuid: "eb8b21af7904c212"));
		results.append(VCS(name: "Fox Sports Houston", uuid: "c4aea043d8de4162"));
		results.append(VCS(name: "Bravo (Pacific Feed)", uuid: "7d7c724df41fcb58"));
		results.append(VCS(name: "Syfy (Pacific Feed)", uuid: "181e10b5c37095f5"));
		results.append(VCS(name: "Nbc Wtvjdt2 Mia", uuid: "0b874bc49123a3b2"));
		results.append(VCS(name: "YES Network", uuid: "b8bd930c4e87c4a1"));
		results.append(VCS(name: "Telemundo New York", uuid: "74ceeb98af4fec7b"));
		results.append(VCS(name: "ABC 13 Houston", uuid: "019a5d2da893a3f0"));
		results.append(VCS(name: "Fox Sports Carolinas (North Carolina)", uuid: "688449e8335b50d0"));
		results.append(VCS(name: "CNN (Spanish)", uuid: "e7df8e48350b8cac"));
		results.append(VCS(name: "Telemundo San Antonio", uuid: "99e7308f70505084"));
		results.append(VCS(name: "My13 Los Angeles", uuid: "ff32075cb6aa4820"));
		results.append(VCS(name: "CSN New England", uuid: "c763342aa5252f1d"));
		results.append(VCS(name: "Fox 7 Miami", uuid: "21a8faf470d19a54"));
		results.append(VCS(name: "CSN Philly/Philadelphia", uuid: "752799769b18bdb3"));
		results.append(VCS(name: "Cozi TV Washington DC", uuid: "739dbec41308d44e"));
		results.append(VCS(name: "MyTV 33 Miami/Fort Lauderdale", uuid: "acd850bd66b73dd0"));
		results.append(VCS(name: "CBS 4 Denver", uuid: "e450792003f7b06b"));
		results.append(VCS(name: "Nbc E (Pacific Feed)", uuid: "0a8e56803ed24787"));
		results.append(VCS(name: "Fox 5 Washington D.C.", uuid: "942b408ad5fa677e"));
		results.append(VCS(name: "ABC 7 New York", uuid: "393285cd7036e69c"));
		results.append(VCS(name: "Fox 4 Dallas", uuid: "e69578c7fc578d9a"));
		results.append(VCS(name: "CBS 3 Grand Rapids", uuid: "6a2a6a8a44dfcd0e"));
		results.append(VCS(name: "Telemundo Boston", uuid: "f56509ed88705f58"));
		results.append(VCS(name: "Fox 51 Gainesville", uuid: "0a8eba85dcb4593b"));
		results.append(VCS(name: "Starz Encore", uuid: "bd7052062205581b"));
		results.append(VCS(name: "Fox Sports Midwest Icb", uuid: "8264fdc71850d1ba"));
		results.append(VCS(name: "Spike (Pacific Feed)", uuid: "6840c2d5d7709752"));
		results.append(VCS(name: "Cozi TV Philadelphia", uuid: "4cb517903da0956d"));
		results.append(VCS(name: "Freeform (Pacific Feed)", uuid: "53db2554eca634f8"));
		results.append(VCS(name: "Fox Sports Southeast Hor", uuid: "494e83b3bdf0a6b8"));
		results.append(VCS(name: "Sho Sho2", uuid: "2e49986175424e80"));
		results.append(VCS(name: "Nbc Chi Wmaqdt2", uuid: "c693344cdbf31bf0"));
		results.append(VCS(name: "Nbc Olympics Bsk", uuid: "b9c7b27a8723a599"));
		results.append(VCS(name: "Vod1", uuid: "72f357c7797e3b31"));
		results.append(VCS(name: "NBC 4 Detroit", uuid: "b27075a8f000cc75"));
		results.append(VCS(name: "Telemundo Philadelphia", uuid: "bd0d954fa7d88459"));
		results.append(VCS(name: "Fox Sports Southeast Atlanta", uuid: "273af9ba4237e65a"));
		results.append(VCS(name: "New England Cable News", uuid: "9d34bdd3d0f726e3"));
		results.append(VCS(name: "Discovery Familia (Spanish)", uuid: "3becb5e44c75c779"));
		results.append(VCS(name: "Esquire (Pacific Feed)", uuid: "56ac8001866b2ff6"));
		results.append(VCS(name: "Fox Sports Florida", uuid: "7cf4f35f481afb7a"));
		results.append(VCS(name: "My27 Dallas", uuid: "a0b220003a61c181"));
		results.append(VCS(name: "Nbc Universo (Spanish)", uuid: "024baf1255e75b54"));
		results.append(VCS(name: "Travel Channel (Pacific Feed)", uuid: "c88fc6290af143fb"));
		results.append(VCS(name: "Fox Sports Southwest Dallas 2", uuid: "ff3da534515cdbb2"));
		results.append(VCS(name: "CBS 2 Salt Lake City", uuid: "ca53830983ea5dbc"));
		results.append(VCS(name: "Fox Sports Southeast HPG", uuid: "b696e543d4141c1e"));
		results.append(VCS(name: "Fox 7 Austin", uuid: "7c6506b99bba057a"));
		results.append(VCS(name: "Telemundo Tucson", uuid: "83fa3a8158bbf633"));
		results.append(VCS(name: "Cozi TV New York", uuid: "a8e3b1662cdbbddb"));
		results.append(VCS(name: "TBS (Pacific Feed)", uuid: "f44ca2b590ac6ad9"));
		results.append(VCS(name: "Oxygen (Pacific Feed)", uuid: "d04f9b70a25c23bd"));
		results.append(VCS(name: "Telemundo Chicago", uuid: "088f2b09c59edbbe"));
		results.append(VCS(name: "Cinemax", uuid: "3bee6cee99ba3a01"));
		results.append(VCS(name: "NBC 11 Bay Area & San Francisco", uuid: "7d0e63ecbc68c9d4"));
		results.append(VCS(name: "Nbc Kxasdt2 Dal", uuid: "eb8a4b79fd4a21f9"));
		results.append(VCS(name: "Cbs Nyc Wcbsdt2 Plus", uuid: "b7725d718a111a11"));
		results.append(VCS(name: "Nbc Ktmddt3 Hou Cozi", uuid: "43cbccf9d730e166"));
		results.append(VCS(name: "ABC 11 Raleigh", uuid: "c92aa56c0ccce5cf"));
		results.append(VCS(name: "CBS 2 Chicago", uuid: "0eca2fe233a54a34"));
		results.append(VCS(name: "Fox Soccer Plus", uuid: "1b5167a61d8656b6"));
		results.append(VCS(name: "NBC 5 Chicago", uuid: "7e1f3d6b2a547989"));
		results.append(VCS(name: "Fox 10 Phoenix", uuid: "e56a450982ea4af1"));
		results.append(VCS(name: "CBS 8 San Diego", uuid: "8825d1ad2ae4d4bc"));
		results.append(VCS(name: "CBS WJZ 13 Baltimore", uuid: "c5f8dc4a2cfd8cf6"));
		results.append(VCS(name: "CBS 42 Austin", uuid: "b526e96c7a6dd5dc"));
		results.append(VCS(name: "NBC 30 Connecticut", uuid: "06375e4d810dc754"));
		results.append(VCS(name: "Fox 46 Charlotte", uuid: "caf8a2d984ed1753"));
		results.append(VCS(name: "My65 Orlando", uuid: "9e8e793dda46fb78"));
		results.append(VCS(name: "CBS 4 Miami–Fort Lauderdale", uuid: "53a668d8936eb7c2"));
		results.append(VCS(name: "NBC 10 Philadelphia", uuid: "2189c6530de021e0"));
		results.append(VCS(name: "MTV Tr3́s (Spanish)", uuid: "ac0589cae8ec0947"));
		results.append(VCS(name: "CW 50 Chicago", uuid: "4c0dcf9bb1c52664"));
		results.append(VCS(name: "Telemundo Houston", uuid: "58c6390f5e34402e"));
		results.append(VCS(name: "CBS 5 Phoenix", uuid: "db945cd5ab260e17"));
		results.append(VCS(name: "Fox 32 Chicago", uuid: "a8fd4e569941076b"));
		results.append(VCS(name: "Telemundo Los Angeles", uuid: "1b732bc590cc9f9d"));
		results.append(VCS(name: "Fox Sports San Diego", uuid: "706c34167e7a6b33"));
		results.append(VCS(name: "CBS 11 Dallas", uuid: "a9caf27560f0ef84"));
		results.append(VCS(name: "Dsc Invest (Pacific Feed)", uuid: "7ec18fa804738647"));
		results.append(VCS(name: "MTV Tr3́s (Spanish) (Pacific Feed)", uuid: "29d61cc2aaab83fd"));
		results.append(VCS(name: "Fox Sports SUN", uuid: "ab80054b90eada14"));
		results.append(VCS(name: "Fox Sports Tennessee", uuid: "9cb4fd0c25dabc74"));
		results.append(VCS(name: "Fox 2 Detroit", uuid: "1d6db1f1c09c4202"));
		results.append(VCS(name: "BBC America", uuid: "23dcc334c6ec6c00"));
		results.append(VCS(name: "Nbc E", uuid: "844b47f684267af4"));
		results.append(VCS(name: "Demn Espn", uuid: "ab1ad8b306d8a5de"));
		results.append(VCS(name: "Vod1", uuid: "05d0068a1b99c00b"));
		results.append(VCS(name: "Cbs Channel 25415", uuid: "2ae783a2b84dc109"));
		results.append(VCS(name: "CSN Bay Area - San Francisco", uuid: "0153eebd284af4c8"));
		results.append(VCS(name: "NBC 6 Miami/Fort Lauderdale", uuid: "8ca0f08774827d23"));
		results.append(VCS(name: "mtvU", uuid: "4fd2946aeac199df"));
		results.append(VCS(name: "Cbs Channel 25413", uuid: "784486ebf4e509ff"));
		results.append(VCS(name: "Cbs Channel 25393", uuid: "db6b6a5fce05d4a1"));
		results.append(VCS(name: "CBS 2 New York", uuid: "17115bb882261a10"));
		results.append(VCS(name: "MTV", uuid: "1e683527faa830fb"));
		results.append(VCS(name: "Fox Sports Southwest Dallas", uuid: "e426a270ef6eb88f"));
		results.append(VCS(name: "My20 Houston", uuid: "7ed1f26b0809c6a1"));
		results.append(VCS(name: "BET (Pacific Feed)", uuid: "0e5e665e0786f4cd"));
		results.append(VCS(name: "Nickelodeon (Pacific Feed)", uuid: "c5b9956c4a152d2c"));
		results.append(VCS(name: "Nbc Universo (Pacific Feed) (Spanish)", uuid: "3bdbe151f714eb67"));
		results.append(VCS(name: "Telemundo", uuid: "b6101b03e44d94ba"));
		results.append(VCS(name: "Telemundo Las Vegas", uuid: "bb94dc414f7e92f1"));
		results.append(VCS(name: "NBA TV", uuid: "24d1379393d0656e"));
		results.append(VCS(name: "Starzencore Starz", uuid: "2197b5a72af1d5d1"));
		results.append(VCS(name: "Cbs Channel 25434", uuid: "720b117d42a37320"));
		results.append(VCS(name: "Nat Geo (Spanish)", uuid: "3443c79ecef34189"));
		results.append(VCS(name: "Cbs Channel 25417", uuid: "f29685241a70617c"));
		results.append(VCS(name: "Discovery Life", uuid: "c7b9db19ef6344ac"));
		results.append(VCS(name: "ESPN Deportes (Spanish)", uuid: "4bbba8b10f14b2db"));
		results.append(VCS(name: "KNBC Los Angeles (NBC 4)", uuid: "066652651bf61a66"));
		results.append(VCS(name: "Fox 5 New York", uuid: "0c7a815cfba87bfd"));
		results.append(VCS(name: "Discovery (Pacific Feed)", uuid: "725d3084a5931fbd"));
		results.append(VCS(name: "CSN Chicago", uuid: "81f55f84c93b2546"));
		results.append(VCS(name: "Telemundo San Francisco", uuid: "9f06209d75209913"));
		results.append(VCS(name: "Fox Sports Midwest Indiana", uuid: "49612b216ea2620b"));
		results.append(VCS(name: "CBS 5 Kansas City", uuid: "1fc8b2adfd566e74"));
		results.append(VCS(name: "Fox Sports Ohio", uuid: "05b2f1d38e2a3ab3"));
		results.append(VCS(name: "Starzencore Starzedge", uuid: "474ca6253a51f9d4"));
		results.append(VCS(name: "Cbs Channel 25398", uuid: "e2d71a51e4ef2d15"));
		results.append(VCS(name: "Cbs Channel 25441", uuid: "e4efec2b00212c42"));
		results.append(VCS(name: "Cbs Channel 25442", uuid: "d1461bcfa8fd266e"));
		results.append(VCS(name: "Telemundo", uuid: "b51825eff3c88f30"));
		results.append(VCS(name: "NBC 7 San Diego", uuid: "ba8a3d9da8ac54cc"));
		results.append(VCS(name: "Fox Sports Ohio", uuid: "40e632e9126d6085"));
		results.append(VCS(name: "NBC 5 Fort Worth", uuid: "4fed4e81a00b7fc5"));
		results.append(VCS(name: "ABC 7 Chicago", uuid: "2d50d9d712972070"));
		results.append(VCS(name: "Fox Sports Southwest Houston 1", uuid: "4e0cfed7e580236f"));
		results.append(VCS(name: "Telemundo Phoenix", uuid: "ad259f7f8441cc03"));
		results.append(VCS(name: "Fox Deportes (Spanish)", uuid: "3973aa5f918c02c2"));
		results.append(VCS(name: "ABC OnDemand", uuid: "dd4c0e3bd7412d9c"));
		results.append(VCS(name: "NBC OnDemand", uuid: "b280fbb0422d56fb"));
		results.append(VCS(name: "Cbs Channel 25440", uuid: "437e825d55dd11d6"));
		results.append(VCS(name: "Cbs Channel 25418", uuid: "be9528faa86cb538"));
		results.append(VCS(name: "Fox Sports Network", uuid: "26de872284f07941"));
		results.append(VCS(name: "Animal Planet", uuid: "4dcc74437e4fc2bf"));
		results.append(VCS(name: "The Comcast Network Boston", uuid: "521c91ca01f98d0e"));
		results.append(VCS(name: "Disney Channel", uuid: "f839b15df3d196c3"));
		results.append(VCS(name: "Centric", uuid: "abece383e3d2ae2b"));
		results.append(VCS(name: "Cbs Channel 25439", uuid: "256ee901760db60c"));
		results.append(VCS(name: "BET", uuid: "9aaa693c252b53bc"));
		results.append(VCS(name: "Cbs Channel 25386", uuid: "14baf9f16bea5f63"));
		results.append(VCS(name: "Fox Chi Wpwrdt2", uuid: "085fe278cb9a18a2"));
		results.append(VCS(name: "Fox Sports Ohio", uuid: "dda2379b2cc40d1c"));
		results.append(VCS(name: "Bravo", uuid: "6f2b4a334245c8c2"));
		results.append(VCS(name: "SundanceTV", uuid: "e13488261070143a"));
		results.append(VCS(name: "Golf Channel", uuid: "117d4466f657aa1d"));
		results.append(VCS(name: "Cartoon Network/Adult Swim", uuid: "8bac778c5e3cb3f5"));
		results.append(VCS(name: "Fox Sports Sun", uuid: "79553f0620d8eb61"));
		results.append(VCS(name: "CSN Northwest", uuid: "d73a6c3357ec9219"));
		results.append(VCS(name: "CMT", uuid: "9dd51291b113985a"));
		results.append(VCS(name: "E!", uuid: "ef96148c7bc4425e"));
		results.append(VCS(name: "Cloo", uuid: "bbe5bf03125a4915"));
		results.append(VCS(name: "Cooking Channel", uuid: "d99d3a565da41d08"));
		results.append(VCS(name: "CBS 13 Sacramento", uuid: "327be59ca1f0f26a"));
		results.append(VCS(name: "CNBC", uuid: "c8a15403f275b18c"));
		results.append(VCS(name: "ESPNU", uuid: "6967f2b1c5a18d86"));
		results.append(VCS(name: "Food Network (Pacific Feed)", uuid: "f6331f99d617beed"));
		results.append(VCS(name: "Destination America", uuid: "d3d6bcf5037b7228"));
		results.append(VCS(name: "WE tv", uuid: "d800b78e78ec4afa"));
		results.append(VCS(name: "CMT Music", uuid: "4cca254620e5183f"));
		results.append(VCS(name: "Esquire Network", uuid: "f353603fa535b132"));
		results.append(VCS(name: "IMPACT", uuid: "6027e415a2dc7700"));
		results.append(VCS(name: "FOX College Sports Central", uuid: "29093d8cab35129d"));
		results.append(VCS(name: "FXX (Pacific Feed)", uuid: "f9ba2ad4023bdf21"));
		results.append(VCS(name: "ESPN", uuid: "533ee05eea7d5b66"));
		results.append(VCS(name: "Nbc Nyc Wnjudt2 Exitos", uuid: "8dbcc6b86a9409e6"));
		results.append(VCS(name: "FXX", uuid: "f8f64cc6acbf5875"));
		results.append(VCS(name: "Cbs Channel 25390", uuid: "0302f2cc63bf83ba"));
		results.append(VCS(name: "Cinemax (Pacific Feed)", uuid: "50db69c1e693ff86"));
		results.append(VCS(name: "Fox Sports Detroit Plus", uuid: "6012e21ad9158401"));
		results.append(VCS(name: "Fox Sports Prime Ticket Clippers", uuid: "009102b5f006fb7d"));
		results.append(VCS(name: "Fox Sports Ohio", uuid: "8939f99fce7caad7"));
		results.append(VCS(name: "CBS 4 El Paso", uuid: "23bd8b23af3fe370"));
		results.append(VCS(name: "FS1", uuid: "2fd361265f0e18b2"));
		results.append(VCS(name: "KTTV Los Angeles (FOX 11)", uuid: "57e334b7bcdd362d"));
		results.append(VCS(name: "FOX 29 Philadelphia ", uuid: "a4b0d0113ceed509"));
		results.append(VCS(name: "Oxygen", uuid: "c94e524e0dee53b1"));
		results.append(VCS(name: "HGTV", uuid: "71f7c9b7e3a3a979"));
		results.append(VCS(name: "Hi-YAH!", uuid: "2eabf2ada149a3f2"));
		results.append(VCS(name: "Telemundo Dallas", uuid: "00cd8fa0027d40b0"));
		results.append(VCS(name: "LOGO", uuid: "60936e92d6c32116"));
		results.append(VCS(name: "Machinima", uuid: "904559ed0c0f03dc"));
		results.append(VCS(name: "My12 Charlotte", uuid: "f72442486e457675"));
		results.append(VCS(name: "Cbs Channel 25429", uuid: "f8ac626e0c7c1c9c"));
		results.append(VCS(name: "CBS 3 Charlotte", uuid: "46d1396e05d9beb9"));
		results.append(VCS(name: "MTV Live", uuid: "5efe76ed070d7903"));
		results.append(VCS(name: "Cbs Channel 25411", uuid: "f55c5bd313498178"));
		results.append(VCS(name: "Starz Comedy", uuid: "cd6c8348ab3c849c"));
		results.append(VCS(name: "NFL Network", uuid: "ae7d286efcd51367"));
		results.append(VCS(name: "Cbs Channel 25431", uuid: "87d38c44c5bd76d2"));
		results.append(VCS(name: "Fox Sports Midwest Mississippi", uuid: "8bfaab0129cfabe0"));
		results.append(VCS(name: "Nickelodeon", uuid: "1c476f1273abf2e3"));
		results.append(VCS(name: "Nicktoons", uuid: "2092c922686e599a"));
		results.append(VCS(name: "Poker Central", uuid: "31f924cf18f2e11a"));
		results.append(VCS(name: "Starz Encore (Pacific Feed)", uuid: "9005c8e1ab733c59"));
		results.append(VCS(name: "Spike", uuid: "6c51ffe46fc2601e"));
		results.append(VCS(name: "Sony Movie Channel", uuid: "bb05efb998dc7cb4"));
		results.append(VCS(name: "Sprout", uuid: "e2b256b042a3e2fe"));
		results.append(VCS(name: "Showtime West", uuid: "bab1a7c35f0bb197"));
		results.append(VCS(name: "CMT (Pacific Feed)", uuid: "a0aec955b75fe6e3"));
		results.append(VCS(name: "Cbs Channel 25426", uuid: "cdc2ba676f36df9c"));
		results.append(VCS(name: "truTV", uuid: "272403cf8511711c"));
		results.append(VCS(name: "TV Land", uuid: "96c1571c7c025cfc"));
		results.append(VCS(name: "Cbs Channel 25422", uuid: "5af15be888dde051"));
		results.append(VCS(name: "CSN Bay Area & San Francisco Plus", uuid: "4542cb6afde05e8a"));
		results.append(VCS(name: "Cbs Channel 25421", uuid: "c4ae33999f279b17"));
		results.append(VCS(name: "Starzencore Encore (Pacific Feed)", uuid: "cbc25373f46122c0"));
		results.append(VCS(name: "Cbs Channel 25400", uuid: "0bb53bc7e7fab251"));
		results.append(VCS(name: "Universal", uuid: "40eecea4c2d28848"));
		results.append(VCS(name: "VH1", uuid: "60cde40fa7676e4e"));
		results.append(VCS(name: "AMC", uuid: "37db3ed9dbaa7691"));
		results.append(VCS(name: "SEC Network", uuid: "caaf3bb41af66b33"));
		results.append(VCS(name: "Disney Junior (Pacific Feed)", uuid: "38d95ea6312c7b6c"));
		results.append(VCS(name: "MTV", uuid: "d766d366264e9608"));
		results.append(VCS(name: "Nick Music", uuid: "0a24bfaae2546f6e"));
		results.append(VCS(name: "Syfy", uuid: "dfcc4d316ce67866"));
		results.append(VCS(name: "My29 Minneapolis", uuid: "870adf8ed4789c5a"));
		results.append(VCS(name: "Fox Sports Midwest BCB", uuid: "7a746f96d7d31126"));
		results.append(VCS(name: "MGM-HD", uuid: "feef937ea8160f20"));
		results.append(VCS(name: "Velocity", uuid: "d0c2b6d689b84434"));
		results.append(VCS(name: "OWN", uuid: "83637b2f7027f314"));
		results.append(VCS(name: "FXM", uuid: "4c83268285eafdaf"));
		results.append(VCS(name: "MTV Classic", uuid: "03ae03ad808dcfc1"));
		results.append(VCS(name: "TeenNick", uuid: "be723d2d92d0efca"));
		results.append(VCS(name: "Investigation Discovery", uuid: "b96e132c85c16045"));
		results.append(VCS(name: "Cbs Channel 25392", uuid: "1235287d101501b8"));
		results.append(VCS(name: "Cbs Channel 25383", uuid: "870d9868461f287d"));
		results.append(VCS(name: "Chiller", uuid: "73806134a337ede4"));
		results.append(VCS(name: "Freeform", uuid: "4eb6de00bd9df7b9"));
		results.append(VCS(name: "Cbs Channel 25420", uuid: "bb15087596789c08"));
		results.append(VCS(name: "Cbs Channel 25427", uuid: "b89c5632a18387f3"));
		results.append(VCS(name: "CBS 13 Portland, Maine", uuid: "6e3b23170af9bec4"));
		results.append(VCS(name: "Nat Geo (Pacific Feed)", uuid: "4e9c9b6ae9c38f9f"));
		results.append(VCS(name: "Cbs Channel 25438", uuid: "2a580470b18116c3"));
		results.append(VCS(name: "Science Channel", uuid: "876aed39b692dc33"));
		results.append(VCS(name: "Comedy Central (Pacific Feed)", uuid: "a3edbb32dadb7322"));
		results.append(VCS(name: "CSN Mid-Atlantic Plus", uuid: "8593bb640ae98695"));
		results.append(VCS(name: "FOX College Sports (Pacific Feed)", uuid: "3bac7a35ff2dda7b"));
		results.append(VCS(name: "FOX Business Channel", uuid: "debbc11ac78ebd13"));
		results.append(VCS(name: "TNT (Pacific Feed)", uuid: "297775a65e3c578d"));
		results.append(VCS(name: "MTV (Pacific Feed)", uuid: "9bfcf950990fc923"));
		results.append(VCS(name: "CBS 4 St. Louis", uuid: "98854e1a109a6430"));
		results.append(VCS(name: "HLN", uuid: "7e60ab397da45ab5"));
		results.append(VCS(name: "HBO (Eastern Feed)", uuid: "8d8ccada857fe9ba"));
		results.append(VCS(name: "Showtime (Eastern Feed)", uuid: "9afe23a5e6d473f9"));
		results.append(VCS(name: "Telemundo 51 Fort Lauderdale/Miami", uuid: "9209d431b6ec9713"));
		results.append(VCS(name: "CBS 16 Salisbury", uuid: "0aad4d77c3aafa62"));
		results.append(VCS(name: "DIY Network", uuid: "77b91e24fbabc8f1"));
		results.append(VCS(name: "Fox 2 San Francisco - Bay Area", uuid: "0d854f3f6b01367e"));
		results.append(VCS(name: "CSN California", uuid: "92815c24606675a0"));
		results.append(VCS(name: "Fox Sports Southwest Dallas Plus", uuid: "1eb58501f0bab37d"));
		results.append(VCS(name: "Fox Sports North Plus", uuid: "f12b5c68cae9c3bd"));
		results.append(VCS(name: "HBO (Pacific Feed)", uuid: "ba47279caea8024a"));
		results.append(VCS(name: "Disney Channel (Pacific Feed)", uuid: "e141a2674167e918"));
		results.append(VCS(name: "Boomerang", uuid: "079620a98672224e"));
		results.append(VCS(name: "ONE World Sports", uuid: "0f1f2437808ef4f2"));
		results.append(VCS(name: "FS2", uuid: "f16a94311d6e0317"));
		results.append(VCS(name: "BET Soul", uuid: "551352a1a279ce0a"));
		results.append(VCS(name: "VH1 (Pacific Feed)", uuid: "3f0070d97d376e78"));
		results.append(VCS(name: "Cbs Channel 25409", uuid: "580617f53451b7a2"));
		results.append(VCS(name: "Cbs Channel 25423", uuid: "05f4bebfbf8aac39"));
		results.append(VCS(name: "EPIX Hits", uuid: "fa97226e28f59d50"));
		results.append(VCS(name: "Fox Sports Wisconsin", uuid: "bd3d7ba7a819f5b3"));
		results.append(VCS(name: "Fox Sports Southeast Wisconsin", uuid: "1a30fa391465eb23"));
		results.append(VCS(name: "CSN Chicago Plus", uuid: "564634f905f5eecd"));
		results.append(VCS(name: "Nick Jr.", uuid: "2637484439ab3a55"));
		results.append(VCS(name: "CBS 19 Cleveland", uuid: "72532b6b0e3a72c0"));
		results.append(VCS(name: "Cbs Channel 25425", uuid: "3838a560696ff660"));
		results.append(VCS(name: "New England Sports Network Boston", uuid: "94308806b9c2a4c7"));
		results.append(VCS(name: "Fox Sports Prime Ticket", uuid: "48023a9e3b22d410"));
		results.append(VCS(name: "Cbs Channel 25396", uuid: "d97675cbf81757f2"));
		results.append(VCS(name: "BTN (Alternate 4)", uuid: "2c6b1fc54ef11058"));
		results.append(VCS(name: "Fox Sports West", uuid: "a3f1459e5c52080c"));
		results.append(VCS(name: "CBS 12 Cincinnati", uuid: "9c286e73560255bd"));
		results.append(VCS(name: "BTN", uuid: "63863b82520d0243"));
		results.append(VCS(name: "Fox 35 Orlando", uuid: "b2013fa994dcf7bc"));
		results.append(VCS(name: "CNBC World", uuid: "c1cb25c46a3471d4"));
		results.append(VCS(name: "NBC 2 Houston", uuid: "a8e4740eab75b1f0"));
		results.append(VCS(name: "Fox Sports Carolinas (North Carolina)", uuid: "ff551cc5a768413e"));
		results.append(VCS(name: "Fox Sports Southwest Mavericks", uuid: "f52a77491e4890eb"));
		results.append(VCS(name: "Food Network", uuid: "aa238b5cadb6bed1"));
		results.append(VCS(name: "Fusion", uuid: "39cc26720d510cf2"));
		results.append(VCS(name: "NFL Redzone", uuid: "eeb129cc99f961fc"));
		results.append(VCS(name: "CNN", uuid: "f179fc1c68617ade"));
		results.append(VCS(name: "Fox Sports Southeast HGR", uuid: "06a506be8182eb22"));
		results.append(VCS(name: "Discovery Family", uuid: "e9e8bc6b0f57c819"));
		results.append(VCS(name: "CBS 3 Philadelphia", uuid: "d669016cecf8d81f"));
		results.append(VCS(name: "Fox Sports Brgpp", uuid: "bf6f556028eb93ef"));
		results.append(VCS(name: "Fox Sports Florida Miami", uuid: "b33bf1273f97571d"));
		results.append(VCS(name: "My20 Washington, D.C", uuid: "c451cb60ab9a65cf"));
		results.append(VCS(name: "TNT", uuid: "58855501a9d3ad76"));
		results.append(VCS(name: "CBS 46 Atlanta", uuid: "7ee3a3e6d03f9324"));
		results.append(VCS(name: "Cbs Channel 25424", uuid: "a57e75e17e6ea078"));
		results.append(VCS(name: "Fox 13 Tampa", uuid: "6ea00d4837161e13"));
		results.append(VCS(name: "ABC 6 Philadelphia", uuid: "901c1038e3c1ac06"));
		results.append(VCS(name: "USA Network (Pacific Feed)", uuid: "4118ba9b6a237b42"));
		results.append(VCS(name: "Cbs Channel 25419", uuid: "5640ec5587aaeb8c"));
		results.append(VCS(name: "ABC 7 San Francisco", uuid: "de1195ab5d5395f4"));
		results.append(VCS(name: "TLC (Pacific Feed)", uuid: "80e24db421ea1451"));
		results.append(VCS(name: "Telemundo Chi Wsnsdt2", uuid: "cc33309b09c27269"));
		results.append(VCS(name: "Fox Sports Southwest RS", uuid: "3f745d5f8ea01b65"));
		results.append(VCS(name: "Fox Sports South", uuid: "ffb79c33b558cc0f"));
		results.append(VCS(name: "Fox Life", uuid: "4c5d25ad51308715"));
		results.append(VCS(name: "Fox 26 Houston", uuid: "f8ad4e8d6824e822"));
		results.append(VCS(name: "Cartoon Network/Adult Swim (Pacific Feed)", uuid: "a79383e7180d94b4"));
		results.append(VCS(name: "CSN California Plus", uuid: "b7b95a23f50fef13"));
		results.append(VCS(name: "Fox Sports Southwest Z1B", uuid: "26a1e9a545d05a6c"));
		results.append(VCS(name: "Animal Planet (Pacific Feed)", uuid: "d8096778600a8141"));
		results.append(VCS(name: "Travel Channel", uuid: "fcbc4e4374a7bf98"));
		results.append(VCS(name: "Disney XD", uuid: "9527edb5db66702b"));
		results.append(VCS(name: "Cbs Channel 25401", uuid: "5f0e8e29166255f6"));
		results.append(VCS(name: "Cbs Channel 25443", uuid: "4d9d9f7365833b5d"));
		results.append(VCS(name: "Cbs Channel 25395", uuid: "d0e660163b709c96"));
		results.append(VCS(name: "Long Horn Network", uuid: "b53b1fd8edf5ef57"));
		results.append(VCS(name: "Cbs Channel 25406", uuid: "9e68a11e2da273e5"));
		results.append(VCS(name: "TLC", uuid: "06cc0eb2d761a5d9"));
		results.append(VCS(name: "FOX News Channel", uuid: "ce8cfa3fad8fbddf"));
		results.append(VCS(name: "MTV2", uuid: "92c1a1b617dbf5cf"));
		results.append(VCS(name: "TBS", uuid: "36369594ba96ccec"));
		results.append(VCS(name: "USA", uuid: "43a91c017541d379"));
		results.append(VCS(name: "BeIN Sports", uuid: "54bd1763e8377568"));
		results.append(VCS(name: "BET Gospel", uuid: "a5017d28e4615981"));
		results.append(VCS(name: "BTN (Alternate 3)", uuid: "d24cc458e162a6ec"));
		results.append(VCS(name: "TLC", uuid: "989754b4907b352b"));
		results.append(VCS(name: "ESPN2", uuid: "84bbdb5e3752d748"));
		results.append(VCS(name: "FOX College Sports Atlantic", uuid: "dfe1d3f34a26bcf7"));
		results.append(VCS(name: "FOX Sports North", uuid: "ebac702bc05158d0"));
		results.append(VCS(name: "FX", uuid: "3338ed3e1423399e"));
		results.append(VCS(name: "IFC", uuid: "5fbd5bb1904af411"));
		results.append(VCS(name: "MSNBC", uuid: "9f01630cc8ecd62d"));
		results.append(VCS(name: "NBC Sports Network", uuid: "f75024e283ef24cf"));
		results.append(VCS(name: "Outside Television", uuid: "f4fa6acfd07d277c"));
		results.append(VCS(name: "POP", uuid: "422394cbf910ccaf"));
		results.append(VCS(name: "Turner Classic Movies", uuid: "877e23063784cb3e"));
		results.append(VCS(name: "BET Jams", uuid: "8b0f8fc22bb879dd"));
		results.append(VCS(name: "ESPNEWS", uuid: "47b3fca3a1d62051"));
		results.append(VCS(name: "American Heroes Channel", uuid: "1c64ba0b9776361c"));
		results.append(VCS(name: "Comedy Central", uuid: "a18b88f4fe623510"));
		results.append(VCS(name: "Nat Geo WILD", uuid: "21e7948b2c6aee31"));
		results.append(VCS(name: "Disney Junior", uuid: "e3f67d4acd90693d"));
		results.append(VCS(name: "Nat Geo Channel", uuid: "d59e26aefc23c5f2"));
		results.append(VCS(name: "BTN (Alternate 2)", uuid: "de7826d895f1fc42"));
		results.append(VCS(name: "Discovery Channel", uuid: "f8c16d53c081ec4e"));
		results.append(VCS(name: "CBS 4 Minneapolis", uuid: "202f24da1da9a43f"));
		results.append(VCS(name: "Fox 9 Minneapolis", uuid: "0fa3c5edec9e0752"));
		results.sort { (a, b) -> Bool in
			return a.name < b.name;
		}
		successCallback(results);
	}
	
	func getURLForStream(
		_ stream: Stream,
		game: Game,
		success successCallback: @escaping (StreamURL) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		let endpoint = HahaService.getURLForStream(streamId: stream.id,
		                                           sport: game.sport.name.lowercased(),
		                                           gameUUID: game.uuid)
		
		self.getOne(endpoint: endpoint,
		            success: successCallback,
		            apiError: errorCallback,
		            networkFailure: failureCallback);
	}
/*
	func getStream(
		channel: Channel,
		success successCallback: @escaping (Stream?) -> Void,
		apiError errorCallback: @escaping (Any) -> Void,
		networkFailure failureCallback: @escaping (MoyaError) -> Void
		)
	{
		
		let endpoint = HahaService.getStreamForChannel(channelId: channel.uuid);
		
		self.getOne(endpoint: endpoint,
		            success: successCallback,
		            apiError: errorCallback,
		            networkFailure: failureCallback);
	}
	*/
	
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
