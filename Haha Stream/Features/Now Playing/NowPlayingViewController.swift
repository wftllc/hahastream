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
	var sections: [[NowPlayingItem]] = [[]];
	
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
		
		self.inlinePlayerContainerView.layer.masksToBounds = true
		self.inlinePlayerContainerView.layer.cornerRadius = 8.0
		self.inlinePlayerContainerView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
		self.inlinePlayerContainerView.layer.shadowRadius = 12;
		self.inlinePlayerContainerView.layer.shadowOpacity = 0.25;
		self.inlinePlayerContainerView.layer.shadowOffset = CGSize(width:0, height:5);

		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false

		interactor?.viewDidLoad();
	}
	/*
	override func showLoading(animated: Bool) {
		self.activityIndicator.startAnimating();
	}
	
	func hideLoading(animated: Bool) {
		self.activityIndicator.stopAnimating();
	}
*/
	
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
	
	override func playStream(stream: Stream, game: Game) {
		interactor?.viewDidSelect(stream: stream, game: game)
	}
	
	func updateView(sections: [[NowPlayingItem]]) {
		self.sections = sections
		self.collectionView.reloadData()
	}
	// MARK: UICollectionViewDataSource
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.sections.count
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		let items = self.sections[section]
		return items.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: NowPlayingHeader.ReuseIdentifier, for: indexPath) as! NowPlayingHeader
//		var text = ""
//		switch(indexPath.section) {
//		case 0:
//			text = "Now Playing"
//		case 1:
//			text = "Channels"
//		case 2:
//			text = "Upcoming"
//		default:
//			text = ""
//		}
//
//		text = text.flatMap { (char) -> String? in
//			return "\(char)\n"
//		}.joined()
//		let attr = header.label.attributedText?.attributes(at: 0, effectiveRange: nil)
//		let s = NSAttributedString(string: text, attributes: attr)
		header.lineView.isHidden = indexPath.section == 0
		header.label.text = nil
		return header
	}
	
	func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
		return IndexPath(item: 0, section: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! NowPlayingViewCell;
		let items = self.sections[indexPath.section]
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

			cell.homeImageView.image = UIImage(named: "hehe-logo-trimmed")
			cell.awayImageView.image = UIImage(named: "hehe-logo-trimmed")
			let away = game.awayTeam.abbreviation ?? String(game.awayTeam.name.prefix(3))
			let home = game.homeTeam.abbreviation ?? String(game.homeTeam.name.prefix(3))
			cell.titleLabel.text = "\(away) @ \(home)"
			cell.sportLabel.text = game.sport.name
			cell.atLabel.isHidden = false
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
				cell.titleLabel.text = channel.title
			cell.timeLabel.text = nil;
			cell.homeImageView.image = nil
			cell.awayImageView.image = nil
			cell.sportLabel.text = channel.sport?.name ?? ""
			cell.atLabel.isHidden = true

//			cell.singleImageView.image = Image(named: "hehelogo-transparent-750.png")
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
			let items = self.sections[indexPath.section]
			interactor?.viewDidUnhighlight(item: items[indexPath.item])
		}
		if let cell = context.nextFocusedView as? NowPlayingViewCell,
			let indexPath = collectionView.indexPath(for: cell) {
			let items = self.sections[indexPath.section]
			interactor?.viewDidHighlight(item: items[indexPath.item])
		}		
	}
	
	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		let items = self.sections[indexPath.section]
		interactor?.viewDidHighlight(item: items[indexPath.item])
	}
	
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		let items = self.sections[indexPath.section]
		interactor?.viewDidUnhighlight(item: items[indexPath.item])
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let items = self.sections[indexPath.section]
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

class NowPlayingHeader: UICollectionReusableView {
	public static let ReuseIdentifier = "NowPlayingHeader"
	@IBOutlet weak var label: UILabel!

	@IBOutlet weak var lineView: UIView!
	override func awakeFromNib() {
		super.awakeFromNib()
		self.lineView.layer.shadowRadius = 12;
		self.lineView.layer.shadowOpacity = 0.25;
		self.lineView.layer.shadowOffset = CGSize(width:0, height:5);
	}
}
