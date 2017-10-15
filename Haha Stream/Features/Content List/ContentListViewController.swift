import UIKit
import Kingfisher
import Moya

private let reuseIdentifier = "ContentListViewCell"

protocol ContentListView: AnyObject {
	var interactor: ContentListInteractor? { get set }
	func updateView(contentList: ContentList)
	func showLoading(animated: Bool)
	func hideLoading(animated: Bool, completion: (()->Void)?)

	func playURL(_ url: URL)
	func showStreamChoiceAlert(game: Game, streams: [Stream])

	var apiErrorClosure: (Any) -> Void { get }
	var networkFailureClosure: (MoyaError) -> Void { get }
}

class ContentListViewController: HahaViewController, ContentListView, DateListDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var inlinePlayerContainerView: UIView!
	@IBOutlet weak var inlineVideoPlayerView: InlineVideoPlayerView!
	
	var interactor: ContentListInteractor?

	var contentList: ContentList?
	
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
	
	//MARK: interactor callbacks
	func updateView(contentList: ContentList) {
		self.contentList = contentList
		self.collectionView.reloadData()
	}
	
	//Mark: DateListDelegate
	
	func dateListDidSelect(date: Date) {
		interactor?.viewDidSelect(date: date)
	}

	// MARK: UICollectionViewDataSource
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return self.contentList?.sections.count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.contentList?.items(inSection: section).count ?? 0
	}
	
	func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
		let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: ContentListHeader.ReuseIdentifier, for: indexPath) as! ContentListHeader

		header.lineView.isHidden = indexPath.section == 0

		return header
	}
	
	func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
		return IndexPath(item: 0, section: 0)
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ContentListViewCell;

		guard let item = self.contentList?.item(atIndexPath: indexPath) else {
			return cell
		}
		
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
			cell.focusedDateLabel.alpha = 0.0
			cell.atLabel.isHidden = false
			if game.isActive {
				cell.updateTimeLabel(withDate: game.startDate);
				cell.startAnimating(date: game.startDate)
				cell.readyLabel.isHidden = true
				cell.focusedDateLabel.isHidden = false
				cell.focusedDateLabel.text = "Now Playing"
				cell.timeLabel.tintColor = cell.readyLabel.tintColor
			}
			else {
				cell.timeLabel.text = timeFormatter.string(from: game.startDate);
				cell.readyLabel.isHidden = false
				cell.focusedDateLabel.isHidden = false
				cell.readyLabel.text = timeFormatter.string(from: game.readyDate);
				cell.focusedDateLabel.text = "Ready at \(timeFormatter.string(from: game.readyDate))"
				cell.timeLabel.tintColor = nil
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
			cell.readyLabel.isHidden = true
			cell.focusedDateLabel.isHidden = true

//			cell.singleImageView.image = Image(named: "hehelogo-transparent-750.png")
		}
		return cell
	}
	
	// MARK: UICollectionViewDelegate
	
	
	func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
		guard let item = self.contentList?.item(atIndexPath: indexPath) else {
			return
		}
		interactor?.viewDidSelect(item: item)
	}

}

class ContentListHeader: UICollectionReusableView {
	public static let ReuseIdentifier = "ContentListHeader"

	@IBOutlet weak var lineView: UIView!
	override func awakeFromNib() {
		super.awakeFromNib()
		self.lineView.layer.shadowRadius = 12;
		self.lineView.layer.shadowOpacity = 0.25;
		self.lineView.layer.shadowOffset = CGSize(width:0, height:5);
	}
}
