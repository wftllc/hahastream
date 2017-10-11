import UIKit
import Kingfisher
import AVKit

private let reuseIdentifier = "NowPlayingViewCell"


class NowPlayingViewController: HahaViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var inlinePlayerContainerView: UIView!
	@IBOutlet weak var inlineVideoPlayerView: InlineVideoPlayerView!
	
	var interactor: NowPlayingInteractor?
	var items: [NowPlayingItem] = [];
	
	var timeFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.current;
		df.dateStyle = .none;
		df.timeStyle = .short;
		return df;
	}()
	
	var dateFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.current;
		df.dateStyle = .long;
		df.timeStyle = .none;
		return df;
	}()
	
	//TODO - show something when no current results
	override func viewDidLoad() {
		super.viewDidLoad()
		
		interactor?.viewDidLoad();
		self.inlinePlayerContainerView.layer.masksToBounds = true
		self.inlinePlayerContainerView.layer.cornerRadius = 8.0
		self.inlinePlayerContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		self.inlinePlayerContainerView.layer.shadowRadius = 12;
		self.inlinePlayerContainerView.layer.shadowOpacity = 0.25;
		self.inlinePlayerContainerView.layer.shadowOffset = CGSize(width:0, height:5);

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		self.collectionView?.reloadData()
	}
	
	override func showLoading(animated: Bool) {
		self.activityIndicator.startAnimating();
	}
	
	func hideLoading(animated: Bool) {
		self.activityIndicator.stopAnimating();
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		interactor?.viewWillAppear(animated)
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillAppear(animated);
		interactor?.viewWillDisappear(animated);
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func updateView(items: [NowPlayingItem]) {
		self.items = items
		self.collectionView.reloadData()
	}
	// MARK: UICollectionViewDataSource
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.items.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NowPlayingViewCell;
		let item = items[indexPath.item];
		
		if let game = item.game {
			//			if let homeImageURL = game.homeTeamLogoURL, let awayImageURL = game.awayTeamLogoURL {
			//				cell.homeImageView.kf.setImage(with: homeImageURL);
			//				cell.awayImageView.kf.setImage(with: awayImageURL);
			//				cell.singleImageView.image = nil
			//			}
			//			else {
			//				cell.homeImageView.image = nil
			//				cell.awayImageView.image = nil
			//				cell.singleImageView.kf.setImage(with: game.singleImageURL,
			//				                                 placeholder: Image(named: "hehelogo-transparent-750.png"),
			//				                                 options: nil,
			//				                                 progressBlock: nil,
			//				                                 completionHandler: nil)
			//			}
			
			cell.titleLabel.text = "\(game.awayTeam.abbreviation) @ \(game.homeTeam.abbreviation)"
			if(game.ready) {
				cell.updateTimeLabel(withDate: game.startDate);
				cell.startAnimating(date: game.startDate)
			}
			else {
				cell.timeLabel.text = timeFormatter.string(from: game.startDate);
			}
		}
		else {
			let channel = item.channel!
			//			cell.titleLabel.text = channel.title
			cell.timeLabel.text = nil;
			cell.homeImageView.image = nil
			cell.awayImageView.image = nil
			cell.singleImageView.image = Image(named: "hehelogo-transparent-750.png")
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forNowPlayingItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forNowPlayingItemAt indexPath: IndexPath) {
		
	}
	// MARK: UICollectionViewDelegate
	
	func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
		return true;
	}
	
	func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if let cell = context.previouslyFocusedView as? NowPlayingViewCell,
			let indexPath = collectionView.indexPath(for: cell) {
			interactor?.viewDidUnhighlight(item: items[indexPath.item])
		}
		if let cell = context.nextFocusedView as? NowPlayingViewCell,
			let indexPath = collectionView.indexPath(for: cell) {
			interactor?.viewDidHighlight(item: items[indexPath.item])
		}
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		interactor?.viewDidHighlight(item: items[indexPath.item])
	}
	
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		interactor?.viewDidUnhighlight(item: items[indexPath.item])
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = items[indexPath.item];
		interactor?.viewDidSelect(item: item)
	}
	
	
	
	//MARK: - Video
	let VideoFadeAnimationDuration = 0.15
	var playerLayerObservationContext: UnsafeMutableRawPointer?
	var isObservingPlayerLayer = false
	
	func showVideo(player: AVPlayer) {
		print("\(#function)")
		inlineVideoPlayerView.player = player
		addPlayerLayerObserver()
	}
	
	func hideVideo() {
		UIView.animate(withDuration: self.VideoFadeAnimationDuration, animations: {
			self.inlinePlayerContainerView.alpha = 0.0
		}, completion: { _ in
			self.removePlayerLayerObserver()
			self.inlineVideoPlayerView.player = nil
		})
	}
	
	//observe player readiness
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context != self.playerLayerObservationContext {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}
		let ready = self.inlineVideoPlayerView.playerLayer.isReadyForDisplay
		print("\(#function), \(ready)")
		if ready {
			self.removePlayerLayerObserver()
			UIView.animate(withDuration: self.VideoFadeAnimationDuration, animations: {
				self.inlinePlayerContainerView.alpha = 0.8
			}, completion: { _ in
			})
		}
	}
	
	private func addPlayerLayerObserver() {
		if isObservingPlayerLayer {
			return
		}
		isObservingPlayerLayer = true
		self.inlineVideoPlayerView.playerLayer.addObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), options: [.new, .initial], context: self.playerLayerObservationContext)
	}
	private func removePlayerLayerObserver() {
		if !isObservingPlayerLayer {
			return
		}
		isObservingPlayerLayer = false
		self.inlineVideoPlayerView.playerLayer.removeObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), context: playerLayerObservationContext)
	}
	
}
