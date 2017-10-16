import UIKit
import Kingfisher
import Moya

private let reuseIdentifier = "ContentListViewCell"

protocol ContentListView: AnyObject {
	var interactor: ContentListInteractor? { get set }
	func updateView(contentList: ContentList, lastSelectedItem: ContentItem?)
	func showLoading(animated: Bool)
	func hideLoading(animated: Bool, completion: (()->Void)?)
	
	func playURL(_ url: URL)
	func showStreamChoiceAlert(game: Game, streams: [Stream])
	
	var apiErrorClosure: (Any) -> Void { get }
	var networkFailureClosure: (MoyaError) -> Void { get }
}

class ContentListViewController: HahaViewController, ContentListView, DateListDelegate, NFLDateListDelegate, UICollectionViewDelegate, UICollectionViewDataSource {
	@IBOutlet weak var collectionView: UICollectionView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var dateLabel: UILabel!
	@IBOutlet weak var inlinePlayerContainerView: UIView!
	@IBOutlet weak var inlineVideoPlayerView: InlineVideoPlayerView!
	@IBOutlet weak var noResultsLabel: UILabel!
	
	var interactor: ContentListInteractor?
	
	var contentList: ContentList?
	var preferredFocusIndexPath: IndexPath?
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] { get {
		let def = super.preferredFocusEnvironments;
		return self.collectionView.preferredFocusEnvironments + def
	}}
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
		self.restoresFocusAfterTransition = false
		self.collectionView.remembersLastFocusedIndexPath = true
		self.collectionView.contentInset = UIEdgeInsetsMake(0, 0, 0, 90)
//		self.clearsSelectionOnViewWillAppear = false
		
		self.dateLabel.text = ""
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
	
	override func showLoading(animated: Bool) {
		self.activityIndicator.startAnimating()
		UIView.animate(withDuration: animated ? 0.25 : 0) {
			self.noResultsLabel.alpha = 0
			self.collectionView.alpha = 0
		}
	}
	
	override func hideLoading(animated: Bool, completion: (() -> Void)?) {
		self.activityIndicator.stopAnimating()
		let duration = animated ? 0.25 : 0
		UIView.animate(withDuration: duration, animations: {
			self.noResultsLabel.alpha = 1
			self.collectionView.alpha = 1
		}) { (_) in
			completion?()
		}
	}
	
	//MARK: - interactor callbacks
	func updateView(contentList: ContentList, lastSelectedItem: ContentItem?) {
		self.contentList = contentList
		self.dateLabel.text = contentList.title

		if let item = lastSelectedItem {
			self.preferredFocusIndexPath = contentList.indexPath(forItem: item)
		}
		self.collectionView.reloadData()
		self.noResultsLabel.isHidden = self.contentList?.sections.count != 0
	}
	
	//MARK: - DateListDelegate
	
	func dateListDidSelect(date: Date) {
		interactor?.viewDidSelect(date: date)
	}
	
	//MARK: - NFLDateListDelegate
	func nflDateDidSelect(_ week: NFLWeek) {
		interactor?.viewDidSelect(nflWeek: week)
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
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! ContentListViewCell;
		
		guard let item = self.contentList?.item(atIndexPath: indexPath) else {
			return cell
		}
		
		cell.update(withContentItem: item, inSection: contentList!.sections[indexPath.section])
		
		return cell
	}
	
	func indexPathForPreferredFocusedView(in collectionView: UICollectionView) -> IndexPath? {
		return self.preferredFocusIndexPath
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
