import UIKit
import Kingfisher
import AVKit

private let reuseIdentifier = "GamesViewCell"

class GamesViewController: HahaViewController, DateListDelegate, UICollectionViewDelegate, UICollectionViewDataSource {

	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var dateLabel: UILabel!
	
	public var sport: Sport!;
	public var date: Date!;
	public var games: [Game]!;
	
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
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.games = [];
		self.date = Date();
		
		refreshData();
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
	}
	
	func dateListDidSelect(date: Date) {
		self.date = date;
		refreshData();
	}
	
	func refreshData() {
		self.activityIndicator.startAnimating()
		let calString = self.dateFormatter.string(from: self.date);
		let dateText:String;
		if( date.isToday ) {
			dateText = "Today, \(calString)";
		}
		else if( date.isTomorrow ) {
			dateText = "Tomorrow, \(calString)";
		}
		else if( date.isYesterday ) {
			dateText = "Yesterday, \(calString)";
		}
		else {
			dateText = calString;
		}
		self.dateLabel.text = dateText;
		self.games = [];
		
		self.collectionView?.reloadData();
		self.provider.getGames(sport: sport, date: date!, success: { (games) in
			self.games = games;
			self.collectionView?.reloadData();
			self.activityIndicator.stopAnimating()
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure
		)
	}
	
	
	// MARK: UICollectionViewDataSource
	
	 func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	 func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.games.count;
	}
	
	 func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! GamesViewCell;
		let game = games[indexPath.item];
//		cell.homeTeamLabel.text = game.homeTeam;
//		cell.awayTeamLabel.text = game.awayTeam;
//		cell.timeLabel.text = dateFormatter.string(from: game.startDate);
//		cell.homeImageView.kf.setImage(with: game.homeTeamLogoURL);
//		cell.awayImageView.kf.setImage(with: game.awayTeamLogoURL);
		
		cell.titleLabel.text = game.title
		
		if(game.isActive) {
			cell.updateTimeLabel(withDate: game.startDate);
			cell.startAnimating(date: game.startDate)
		}
		else {
			cell.timeLabel.text = timeFormatter.string(from: game.startDate);
		}
		return cell
	}
	
	func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
	}
	
	func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
		
	}
	// MARK: UICollectionViewDelegate
	
	 func collectionView(_ collectionView: UICollectionView, shouldHighlightItemAt indexPath: IndexPath) -> Bool {
		return true
	}
	
	 func collectionView(_ collectionView: UICollectionView, canFocusItemAt indexPath: IndexPath) -> Bool {
		return true;
	}

	 func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		let game = games[indexPath.item];
		selectGame(game)
	}
	
	
	/*
	// Uncomment this method to specify if the specified item should be selected
	override func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
	return true
	}
	*/
	
	/*
	// Uncomment these methods to specify if an action menu should be displayed for the specified item, and react to actions performed on the item
	override func collectionView(_ collectionView: UICollectionView, shouldShowMenuForItemAt indexPath: IndexPath) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
	return false
	}
	
	override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
	
	}
	*/
	
}
