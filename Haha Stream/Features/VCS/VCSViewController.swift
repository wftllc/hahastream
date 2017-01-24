import UIKit
import Kingfisher
import AVKit

private let reuseIdentifier = "VCSViewCell"


class VCSViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource {
	
	@IBOutlet weak var collectionView: UICollectionView!
	
	public var provider: HahaProvider!;
	public var date: Date!;
	public var items: [VCS]!;
	
	override func viewDidLoad() {
		print("nowPlayingViewController.viewDidLoad()");
		super.viewDidLoad()
		
		self.items = [];
		// Uncomment the following line to preserve selection between presentations
		// self.clearsSelectionOnViewWillAppear = false
		
		refreshData();
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	func refreshData() {
		self.items = [];
		self.collectionView?.reloadData();
		self.provider.getVCSChannels(success: { (results) in
				self.items = results;
				self.collectionView?.reloadData();
			}, apiError: self.apiErrorClosure, networkFailure: self.networkFailureClosure)
	}
	
	// MARK: UICollectionViewDataSource
	
	func numberOfSections(in collectionView: UICollectionView) -> Int {
		return 1
	}
	
	func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
		return self.items.count;
	}
	
	func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
		let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! VCSViewCell;
		let item = items[indexPath.item];
			cell.titleLabel.text = item.name
			cell.timeLabel.text = nil;
			cell.homeImageView.image = nil
			cell.awayImageView.image = nil
			cell.singleImageView.kf.setImage(with: item.imageURL,
			                                 placeholder: Image.init(named: "hehelogo750.png"),
			                                 options: nil,
			                                 progressBlock: nil,
			                                 completionHandler: nil)
		
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
		let item = items[indexPath.item];
		selectItem(item)
	}
	
	func selectItem(_ item: VCS) {
		//TODO: Show loading here
		
		provider.getVCSStreams(vcs: item, success: { (streams) in
			print(streams);
			if streams.count > 0 {
				self.playURL(streams.first!.url)
			}
			else {
				self.showAlert(title: "No \(item.name) Stream", message: "No stream could be found for \(item.name); try again if you like.");
			}
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
