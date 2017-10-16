import UIKit
import AVKit

class VCSViewController: HahaSplitViewController, UISplitViewControllerDelegate, VCSChannelListDelegate {
	var activeVCS: Channel?;
	var playerViewController: AVPlayerViewController? {
		return self.viewControllers.last as? AVPlayerViewController
	}

	override func viewDidLoad() {
		super.viewDidLoad()
		self.delegate = self
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}

	func vcsChannelListDidFocus(channel: Channel) {
	}


	func vcsChannelListDidSelect(channel: Channel) {
		if channel.uuid == activeVCS?.uuid {
			return;
		}
		activeVCS = channel;
		provider.getStream(channel: channel, success: { (stream) in
			if( self.activeVCS?.uuid != channel.uuid ) {
				return;
			}
			self.provider.getStreamURL(forStream: stream, inChannel: channel, success: { (streamURL) in
				if( self.activeVCS?.uuid != channel.uuid ) {
					return;
				}
				self.previewURL(streamURL.url)
			}, apiError: self.apiErrorClosure, networkFailure: self.networkFailureClosure)
		}, apiError: self.apiErrorClosure, networkFailure: self.networkFailureClosure)
	}
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.playerViewController?.player?.pause()
	}
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		self.playerViewController?.player?.play()
	}

	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		var def = super.preferredFocusEnvironments;
		if let masterVC = self.viewControllers.first {
			//make sure the master vc is first (this is an issue after escaping from fullscreen avplayer)
			def.insert(masterVC, at: 0)
		}
		return def;
	}
	
	override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
		//print("shouldUpdateFocus: \(context.previouslyFocusedView) => \(context.nextFocusedView)")
		let def = super.shouldUpdateFocus(in: context);
		if context.previouslyFocusedView is VCSChannelListCell &&
			context.focusHeading == .right {
			return self.playerViewController != nil
		}
		else {
			return def
		}
	}

	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		//print("didUpdateFocus: \(context.previouslyFocusedView) => \(context.nextFocusedView)")

		if context.previouslyFocusedView is VCSChannelListCell &&
			context.focusHeading == .right {
			if self.playerViewController != nil {
				coordinator.addCoordinatedAnimations({ 
					self.preferredDisplayMode = .primaryHidden
				}, completion: nil)
			}
		}
	}
	
	

	func previewURL(_ url: URL) {
		// Create an AVPlayer, passing it the HTTP Live Streaming URL.
		let player = AVPlayer(url: url)
		
		// Create a new AVPlayerViewController and pass it a reference to the player.
		player.play()
		
		if let controller = self.playerViewController {
			controller.player = player
		}
		else {
			let controller = AVPlayerViewController()
			controller.player = player
			self.showDetailViewController(controller, sender: nil)
		}
	}
	
	//MARK - UISplitViewControllerDelegate
	
	 public func splitViewController(_ svc: UISplitViewController, willChangeTo displayMode: UISplitViewControllerDisplayMode)
	{
		//print("willChangeTo \(displayMode.rawValue)")
		if( displayMode == .allVisible ) {
			self.setNeedsFocusUpdate()
			self.updateFocusIfNeeded()
		}
	}
}
