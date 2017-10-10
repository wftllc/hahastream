import UIKit
import Kingfisher
import AVKit

private let reuseIdentifier = "NowPlayingViewCell"


class NowPlayingViewController: HahaViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var dateLabel: UILabel!
	
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
	
	func collectionView(_ collectionView: UICollectionView, shouldHighlightNowPlayingItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	func collectionView(_ collectionView: UICollectionView, canFocusNowPlayingItemAt indexPath: IndexPath) -> Bool {
		return true;
	}
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let item = items[indexPath.item];
		interactor?.viewDidSelect(item: item)
	}
	


	/*
	// Uncomment this method to specify if the specified item should be selected
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
	override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForNowPlayingItemAt indexPath: IndexPath) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forNowPlayingItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forNowPlayingItemAt indexPath: IndexPath, withSender sender: Any?) {
	
	}
	*/
	
}
