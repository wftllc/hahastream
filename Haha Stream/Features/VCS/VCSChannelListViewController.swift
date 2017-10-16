import UIKit

protocol VCSChannelListDelegate: class {
	func vcsChannelListDidSelect(channel: Channel);
	func vcsChannelListDidFocus(channel: Channel);
}

class VCSChannelListViewController: HahaTableViewController {
	weak var delegate: VCSChannelListDelegate?;
	public var items: [Channel] = [];
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.items = [];
		refreshData();
		tableView.remembersLastFocusedIndexPath = true;
	}
	
	
	func refreshData() {
		self.items = [];
		self.provider.getChannels(success: { (results) in
			self.items = results.sorted { $0.title < $1.title };
			self.tableView?.reloadData();
		}, apiError: self.apiErrorClosure, networkFailure: self.networkFailureClosure)
		
	}
	
	override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
//		print("shouldUpdateFocus: \(context.previouslyFocusedView) => \(context.nextFocusedView)")
		return super.shouldUpdateFocus(in: context)
	}
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//		print("didUpdateFocus: \(context.previouslyFocusedView) => \(context.nextFocusedView)")
	}
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.items.count;
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "VCSChannelListCell", for: indexPath) as! VCSChannelListCell;
		let channel = self.items[indexPath.row]

		cell.textLabel?.text = channel.title;
		cell.ourImageView?.kf.setImage(with: channel.logoURL)
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let vcs = self.items[indexPath.row]
		self.delegate?.vcsChannelListDidSelect(channel: vcs)
	}
	
	override func tableView(_ tableView: UITableView, didUpdateFocusIn context: UITableViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if let cell = context.nextFocusedView as? VCSChannelListCell {
				let index = tableView.indexPath(for: cell)
				self.delegate?.vcsChannelListDidFocus(channel: items[index!.row])
		}
	}
}
