/**

This VC subclasses AVPlayerViewController, which the online docs suggest you shouldn't do

Inline docs don't care as much?
**/

//TODO: refactor to not subclass AVPlayerViewController?
import UIKit
import AVKit

class SeekOperation {
	static public let SeekUXTimeoutSeconds: TimeInterval = -1.5
	
	var completionDate: Date?
	var initialMediaTime: CMTime
	//	var targetMediaTime: CMTime
	var increment: Int
	
	/*
	tells is this op is still active. a seek is active if < SeekUxTimeSeconds
	have elapsed since the seek completed
	*/
	var active: Bool {
		return self.completionDate == nil || self.completionDate!.timeIntervalSinceNow > SeekOperation.SeekUXTimeoutSeconds
	}
	
	init(initialMediaTime: CMTime, increment: Int) {
		self.initialMediaTime = initialMediaTime
		self.increment = increment;
	}
	
	func incrementBy(_ by: Int) {
		//TODO: seek gets asymmetrical around the transition points when changing direction
		
		//reset completion date
		self.completionDate = nil
		switch(abs(increment)) {
		case 0..<6: // 0 .. <3 min in 0:30s
			self.increment += by;
		case 6..<10: //3 .. <5 min in 1m
			self.increment += by * 2
		case 10..<60: //5 .. < 30 min by 5m
			self.increment += by * 2 * 5;
		default: // 10 min incr
			self.increment += by * 2 * 10;
		}
	}
}

class PlayerViewController: AVPlayerViewController {
	var seekOperation: SeekOperation?
	
	var overlayView: PlayerOverlayView!;
	
	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
		self.isSkipForwardEnabled = false;
		self.isSkipBackwardEnabled = false;
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		requiresLinearPlayback = false;
		
		self.overlayView = PlayerOverlayView().fromNibNamed("PlayerOverlayView")
		
		print(overlayView);
		overlayView.alpha = 0.0;
		self.contentOverlayView?.addSubview(overlayView)
		
		
		let swipeRecognizerL = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeLeft(_:)))
		let swipeRecognizerR = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeRight(_:)))
		
		swipeRecognizerL.direction = .left
		self.view.addGestureRecognizer(swipeRecognizerL)
		swipeRecognizerR.direction = .right
		self.view.addGestureRecognizer(swipeRecognizerR)
		
		setupObservers()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		super.viewDidAppear(animated)
		overlayView.center = CGPoint(x: self.contentOverlayView!.bounds.width/2, y: self.contentOverlayView!.bounds.height/2)
		self.overlayView.frame = self.contentOverlayView!.bounds
		self.overlayView?.center = CGPoint(x: self.contentOverlayView!.bounds.width/2, y: self.contentOverlayView!.bounds.height/2)
		self.overlayView.alpha = 1.0;
		self.overlayView.label.alpha = 0.0;
		self.overlayView.visualEffectView.alpha = 0.0;
		UIView.animate(withDuration: 0.5, delay: 1, options:[], animations: {
			self.overlayView.visualEffectView.alpha = 1.0;
		}) { (finished) in
			UIView.animate(withDuration: 0.5, delay: 3, animations: {
				self.overlayView.visualEffectView.alpha = 0.0;
			});
		}
		
		debugItem()
		
		DispatchQueue.main.asyncAfter(deadline: .now() + 10.5) {
			self.debugItem()
		}
		//FIXME: remove
		player?.isMuted = true
	}
	
	func debugItem() {
		print("=============DEBUG ITEM==============")
		guard let item = self.player?.currentItem else { return }
		print(item)
		print("duration",item.duration.desc)
		print(item.asset)
		print("tracks",item.tracks)
		print("timeMetadata",item.timedMetadata)
		print("loadedKeys",item.automaticallyLoadedAssetKeys)
		print("canFF",item.canPlayFastForward)
		print("canFR",item.canPlayFastReverse)
		print("forwardEndTime",item.forwardPlaybackEndTime.desc)
		print("reverseEndTime",item.reversePlaybackEndTime.desc)
		for tr in item.seekableTimeRanges {
			if let tr = tr as CMTimeRange? {
				print("seekableTime")
				CMTimeRangeShow(tr)
			}
			else {
				print("seekableTime ", tr)
			}
		}
		print("currentDate",item.currentDate())
		print("currentTime",item.currentTime().desc)
		print(item.canUseNetworkResourcesForLiveStreamingWhilePaused)
		print("externalMetadata",item.externalMetadata)
		
		print("--asset--")
		let asset = item.asset
		print("duration",asset.duration.desc)
		print("metadata",asset.metadata)
	}
	
	func seekBy(_ increment: Int) {
		guard let player = self.player else {
			return;
		}
		
		if( self.seekOperation == nil || !self.seekOperation!.active ) {
			//new seek op!
			self.seekOperation = SeekOperation(initialMediaTime: player.currentTime(), increment: 0)
		}
		
		guard var seekOp = self.seekOperation else { return }
		
		seekOp.incrementBy(increment);
		
		let offsetSeconds: Int = seekOp.increment * 30;
		let targetSeekTime = CMTime(seconds: seekOp.initialMediaTime.seconds+Double(offsetSeconds), preferredTimescale: seekOp.initialMediaTime.timescale);
		
		let s = abs(offsetSeconds) % 60
		let m = abs(offsetSeconds) / 60
		let text = String(format:"%@%0d:%02d", offsetSeconds > 0 ? "+" : "-", m, s)
		self.overlayView.label.text = text;
		
		let options: UIViewAnimationOptions = [.curveEaseOut, .beginFromCurrentState]
		UIView.animate(withDuration: 0.15, delay: 0,
		               options: options,
		               animations: {
										self.overlayView.visualEffectView.alpha = 0.0;
										self.overlayView.label.alpha = 1.0;
		}, completion:nil)
		
		player.seek(to: targetSeekTime) { finished in
			if finished {
				let options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseInOut, .beginFromCurrentState]
				seekOp.completionDate = Date();
				UIView.animate(withDuration: abs(SeekOperation.SeekUXTimeoutSeconds-0.25),
				               delay: 0.0,
				               options: options,
				               animations: {
												self.overlayView.label.alpha = 0.0;
				}) { finished in
				};
			}
		}
	}
	
	func handleSwipeLeft(_ gestureRecognizer: UISwipeGestureRecognizer) {
		seekBy(-1)
	}
	
	func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer) {
		seekBy(1)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	public func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
		print("scrubbed from \(oldTime.seconds) to \(targetTime.seconds)");
	}
	
//mark - player kvo
	
	var playerContext = true
	var playerStatusContext = true
	var playerAssetDurationContext = true
	
	deinit {
			removeObservers()
	}

	
	func removeObservers() {
		self.removeObserver(self, forKeyPath: #keyPath(player))
	}
	
	func setupObservers() {
		
		self.addObserver(self, forKeyPath: #keyPath(player), options: [.initial, .new], context:&playerContext)
	}
	
	func observePlayer(_ player: AVPlayer) {
		//player.status
		player.addObserver(self, forKeyPath: "status", options: [.initial, .new], context: &playerStatusContext)
		
		player.addObserver(self, forKeyPath: "player.currentItem.duration", options: [.initial, .new], context: &playerAssetDurationContext)
	}
	

	func unobservePlayer(_ player: AVPlayer? ){
		guard let player = player else { return }
		player.removeObserver(self, forKeyPath: "status")
		player.removeObserver(self, forKeyPath: "player.currentItem.duration")
	}
	override func observeValue(forKeyPath keyPath: String?,
	                           of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?) {
		// Only handle observations for the playerItemContext
		if context == nil {
			super.observeValue(forKeyPath: keyPath,
			                   of: object,
			                   change: change,
			                   context: context)
			return
		}

		if context == &playerContext {
			if let newPlayer = change?[.newKey] as? AVPlayer {
				print("new player!", newPlayer);
				unobservePlayer(change?[.oldKey] as? AVPlayer)
				observePlayer(newPlayer)
				
			}
		}
		else if context == &playerStatusContext {
			if let statusNumber = change?[.newKey] as? NSNumber {
				let newStatus = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
				print("new status!", newStatus.rawValue);
			}
		}
		else if context == &playerAssetDurationContext {
			print("duration", self.player?.currentItem?.duration.desc ?? "nada")
			//TODO: setup scrubbing and UX as needed
		}
		
	}
	
}


extension CMTime {
	var desc: String {
		
		var o = flags.contains(.valid) ? "valid" : "invalid"
		if flags.contains(.indefinite) { o.append(", indefinite") }
		if flags.contains(.negativeInfinity) { o.append(", -inf") }
		if flags.contains(.positiveInfinity) { o.append(", +inf") }
		var s = String(format:"%@, %.0f sec", o, seconds )
		return s;
	}
}

