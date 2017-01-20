import UIKit
import Kingfisher
import AVKit

private let reuseIdentifier = "GamesViewCell"

class GamesViewController: UIViewController, DateListDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet weak var collectionView: UICollectionView!
	
	public var sport: Sport!;
	public var provider: HahaProvider!;
	public var date: Date!;
	public var games: [Game]!;
	@IBOutlet weak var dateLabel: UILabel!
	
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
		print("gamesViewController.viewDidLoad()");
		super.viewDidLoad()
		
		self.games = [];
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		// Register cell classes
		//		self.collectionView!.register(GamesViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)
		self.date = Date();
		
		refreshData();
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func dateListDidSelect(date: Date) {
		self.date = date;
		refreshData();
	}
	
	func refreshData() {
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
		cell.homeImageView.kf.setImage(with: game.homeTeamLogoURL);
		cell.awayImageView.kf.setImage(with: game.awayTeamLogoURL);
		if( ["NBA"].contains(self.sport.name) && game.awayTeamName != nil && game.homeTeamName != nil) {
			//shorten game titles
			cell.titleLabel.text = "\(game.awayTeamName!) @ \(game.homeTeamName!)"
		}
		else {
			cell.titleLabel.text = game.title
		}
		if(game.ready) {
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
	
	func selectGame(_ game: Game) {
		//TODO: Show loading here
		provider.getStreams(sport: sport, game: game, success: { (streams) in
			self.showStreamChoiceAlert(game: game, streams: streams);
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure
		)
	}
	
	/// Shows an alert with "OK" and "Cancel" buttons.
	func showStreamChoiceAlert(game: Game, streams: [Stream]) {
		let title = "Choose Stream"
		let message: String;
		if let awayTeam = game.awayTeam, let homeTeam = game.homeTeam {
			message = "\(awayTeam) at \(homeTeam)";
		}
		else {
			message = game.title;
		}

		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		for stream in streams {
			// Create the actions.
//			print("available stream \(stream)")
			let title = "\(stream.source) stream";
			let acceptAction = UIAlertAction(title: title, style: .default) { _ in
				//if stream expires in less than one second, refresh and play it
//				print("play stream \(stream)")
				if( stream.expiresAt.timeIntervalSinceNow <= 1 ) {
					self.playStream(source: stream.source, game: game);
				}
				else {
					self.playURL(stream.url);
				}
			}
			alertController.addAction(acceptAction)
		}
		
		let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
		let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	func playStream(source: String, game: Game) {
		provider.getStreams(sport: sport, game: game, success: { (streams) in
			for stream in streams {
				if( stream.source == source ) {
					self.playURL(stream.url);
					return;
				}
			}
			self.showAlert(title: "Stream not Found", message: "A matching stream could not be found. Please try again.");
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure
		)
		
	}
	
	func playURL(_ url: URL) {
		// Create an AVPlayer, passing it the HTTP Live Streaming URL.
		let player = AVPlayer(url: url)
		
		// Create a new AVPlayerViewController and pass it a reference to the player.
		let controller = AVPlayerViewController()
		controller.player = player
		
		// Modally present the player and call the player's play() method when complete.
		present(controller, animated: true) {
			player.play()
		}

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
