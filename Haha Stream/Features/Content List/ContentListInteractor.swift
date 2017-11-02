import UIKit

protocol ContentListInteractor {
	weak var view: ContentListView? { get }
	
	func viewDidLoad()
	func viewWillAppear(_ animated: Bool)
	func viewWillDisappear(_ animated: Bool)
	func viewDidSelect(item: ContentItem)
	func viewDidSelect(stream: Stream, game: Game)
	func viewDidSelect(date: Date)
	func viewDidSelect(nflWeek: NFLWeek)
}

class ContentListInteractorImpl: NSObject, ContentListInteractor {
	let RefreshTimeInterval: TimeInterval = 300;

	var view: ContentListView? { get {
		return self.viewStorage
		}
	}
	weak var viewStorage: ContentListView?
	let provider: HahaProvider
	let router: AppRouter?
	var sport: Sport?

	var timer: Timer?;
	var date: Date?
	var nflWeek: NFLWeek?
	var lastSelectedItem: ContentItem?
	
	init(view: ContentListView?, provider: HahaProvider, router: AppRouter, sport: Sport? = nil) {
		self.viewStorage = view
		self.provider = provider
		self.router = router
		self.sport = sport
	}
	
	func viewDidLoad() {
		refreshData(showLoading: true);
	}
	
	func viewWillAppear(_ animated: Bool) {
		refreshData()
		startTimer()
	}
	
	func viewWillDisappear(_ animated: Bool) {
		self.timer?.invalidate();
	}
	
	func startTimer() {
		self.timer?.invalidate()
		self.timer = Timer.scheduledTimer(withTimeInterval: RefreshTimeInterval, repeats: true) { (timer) in
			self.refreshData()
		};
	}
	
	func refreshData(showLoading: Bool = false) {
		if showLoading {
			self.view?.showLoading(animated: true);
		}
		if let sport = sport {
			if let nflWeek = nflWeek, sport.name.lowercased() == "nfl" {
				self.provider.getNFLContentList(week: nflWeek,
					success: { (contentList) in
						if showLoading {
							self.view?.hideLoading(animated: true, completion: nil)
						}
						self.view?.updateView(contentList: contentList, lastSelectedItem: self.lastSelectedItem)
				}, apiError: self.view!.apiErrorClosure,
				   networkFailure: self.view!.networkFailureClosure
				)

			}
			else {
				self.provider.getContentList(
					sport: sport,
					date: self.date,
					success: { (contentList) in
						if showLoading {
							self.view?.hideLoading(animated: true, completion: nil)
						}
						self.view?.updateView(contentList: contentList, lastSelectedItem: self.lastSelectedItem)
				}, apiError: self.view!.apiErrorClosure,
					 networkFailure: self.view!.networkFailureClosure
				)
			}
		}
		else {
			self.provider.getContentList(
				success: { (contentList) in
					if showLoading {
						self.view?.hideLoading(animated: true, completion: nil)
					}
					self.view?.updateView(contentList: contentList, lastSelectedItem: self.lastSelectedItem)
			}, apiError: self.view!.apiErrorClosure,
			   networkFailure: self.view!.networkFailureClosure
			)
		}
	}
	
	func viewDidSelect(item: ContentItem) {
		self.lastSelectedItem = item
		if let game = item.game {
			selectGame(game);
		}
		else {
			selectChannel(item.channel!);
		}
	}
	
	func viewDidSelect(stream: Stream, game: Game) {
		view?.showLoading(animated: true)
		self.play(stream: stream, inGame: game)
	}

	func viewDidSelect(date: Date) {
		self.date = date		
		self.refreshData(showLoading: true)
	}
	
	func viewDidSelect(nflWeek: NFLWeek) {
		self.nflWeek = nflWeek
		self.refreshData(showLoading: true)
	}

	func selectGame(_ game: Game) {
		view?.showLoading(animated: true)
		provider.getStreams(game: game, success: { (streams) in
			if streams.count == 1 {
				self.play(stream: streams[0], inGame: game)
			}
			else {
				self.view?.hideLoading(animated: true) {
					self.view?.showStreamChoiceAlert(game: game, streams: streams)
				}
			}
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}

	func selectChannel(_ channel: Channel) {
		view?.showLoading(animated: true);
		provider.getStream(channel: channel, success: { (stream) in
			self.play(stream: stream, inChannel: channel)
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}

	func play(stream: Stream, inGame game: Game) {
		self.provider.getStreamURL(forStream: stream, inGame: game, success: { (streamURL) in
			self.view?.hideLoading(animated: false) {
				self.view?.playURL(streamURL.url);
			}
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}

	func play(stream: Stream, inChannel channel: Channel) {
		self.provider.getStreamURL(forStream: stream, inChannel: channel, success: { (streamURL) in
			self.view?.hideLoading(animated: false) {
				self.view?.playURL(streamURL.url);
			}
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}
	
	func play(streamURL: StreamURL) {
		self.view?.playURL(streamURL.url);
	}
	
}
