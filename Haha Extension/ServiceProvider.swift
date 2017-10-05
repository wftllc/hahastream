import Foundation
import TVServices


class ServiceProvider: NSObject, TVTopShelfProvider {
	let provider: HahaProvider
	let RefreshTimeInterval: TimeInterval = 30;
	var contentItems: [TVContentItem] = [];
	
	override init() {
		
		provider = HahaProvider(apiKey: AppProvider.apiKey)
		super.init()
//		start()
		
	}
	
	func start() {
		refresh();
	}
	
	func refresh(after: TimeInterval?) {
		DispatchQueue.main.asyncAfter(deadline: .now() + (after ?? 0)) {
			self.refresh();
		}
	}
	
	func refresh() {
		if !AppProvider.isLoggedIn {
			self.refresh(after: self.RefreshTimeInterval);
			return
		}
		provider.getNowPlaying(success: { [weak self] (nowPlayingItems) in
			DispatchQueue.global(qos: .background).sync {
				self?.process(items: nowPlayingItems);
			}
			self?.refresh(after: self?.RefreshTimeInterval);
		}, apiError: { [weak self] (error) in
			print(error)
			self?.refresh(after: self?.RefreshTimeInterval);
		}, networkFailure:  { [weak self] (error) in
			print(error)
			self?.refresh(after: self?.RefreshTimeInterval);
		})
	}
	
	func process(items: [NowPlayingItem]) {
		//sort back into ready, channels, and upcoming
		let games = items.filter{ $0.game != nil }.map{ $0.game! }.filter{  $0.sport.name.lowercased() != "vcs" }
		let channels = items.filter{ $0.channel != nil }.map{ $0.channel! }
		
		let readyGames = games.filter{ $0.active }
		let upcomingGames:[Game] = games.filter{ $0.upcoming }
		let finalItems:[LocalImage] = readyGames as [LocalImage] + upcomingGames as [LocalImage] + channels as [LocalImage]
		
		//apple tv seems to freak out (memory errors?) if we try to do too many of these at once, so we serialize it
		//still has some tendency to krash
		DispatchQueue.global().async {
			for item in finalItems {
				let semaphore = DispatchSemaphore(value: 0);
				if( !item.localImageExists) {
					item.saveLocalImage{ (url, error) in
						if let error = error {
							print(error)
						}
						semaphore.signal()
					}
				}
				else {
					semaphore.signal()
				}
				var _ = semaphore.wait(timeout: DispatchTime.now() + 60)
				
			}
			NotificationCenter.default.post(name: NSNotification.Name.TVTopShelfItemsDidChange, object: nil);
		}
		//TODO: fetch bundle id? put group into constant?
		//TODO: don't hardcode group id?
		//TODO: notification of login to get api key? (or is just using latest OK?)
		
		
		guard let ident = TVContentIdentifier(identifier: "com.wftllc.haha-stream.games-ready", container: nil) else { fatalError("Error creating content identifier for section item.") }
		guard let readySection = TVContentItem(contentIdentifier: ident) else { fatalError("Error creating section content item.") }
		readySection.title = "Now Playing"
		readySection.topShelfItems = readyGames.flatMap{ TVContentItem(game: $0) }
		
		guard let ident2 = TVContentIdentifier(identifier: "com.wftllc.haha-stream.channels", container: nil) else { fatalError("Error creating content identifier for section item.") }
		guard let channelSection = TVContentItem(contentIdentifier: ident2) else { fatalError("Error creating section content item.") }
		channelSection.title = "Channels"
		channelSection.topShelfItems = channels.flatMap{ TVContentItem(channel: $0) }
		
		guard let ident3 = TVContentIdentifier(identifier: "com.wftllc.haha-stream.games-upcoming", container: nil) else { fatalError("Error creating content identifier for section item.") }
		guard let upcomingSection = TVContentItem(contentIdentifier: ident3) else { fatalError("Error creating section content item.") }
		upcomingSection.title = "Upcoming"
		upcomingSection.topShelfItems = upcomingGames.flatMap{ TVContentItem(game: $0) }
		
		self.contentItems = [
			readySection,
			channelSection,
			upcomingSection,
		]

		NotificationCenter.default.post(name: NSNotification.Name.TVTopShelfItemsDidChange, object: nil);
	}
	// MARK: - TVTopShelfProvider protocol
	
	var topShelfStyle: TVTopShelfContentStyle {
		// Return desired Top Shelf style.
		return .sectioned
	}
	
	var topShelfItems: [TVContentItem] {
		// Create an array of TVContentItems.
		return self.contentItems
	}
}

extension TVContentItem {
	/*
	contentItem.title = dataItem.title
	contentItem.displayURL = dataItem.displayURL
	contentItem.imageURL = dataItem.imageURL
	contentItem.imageShape = imageShape
	*/
	convenience init?(game: Game) {
		guard let identifier = TVContentIdentifier(identifier: "com.wftllc.haha-stream.game.\(game.uuid)", container: nil) else {
			fatalError("Error creating content identifier for game.")
		}
		self.init(contentIdentifier: identifier);
		
		self.title = game.title
		self.imageURL = game.singleImageLocalURL;
		self.imageShape = .poster
		self.playURL = game.playActionURL
		self.displayURL = game.displayActionURL;
		
	}
	
	convenience init?(channel: Channel) {
		guard let identifier = TVContentIdentifier(identifier: "com.wftllc.haha-stream.channel.\(channel.identifier)", container: nil) else {
			fatalError("Error creating content identifier for game.")
		}
		self.init(contentIdentifier: identifier);
		self.imageShape = .poster
		self.imageURL = channel.singleImageLocalURL;
		self.playURL = channel.playActionURL
		self.displayURL = channel.displayActionURL;
		
		self.title  = channel.title
	}
}

