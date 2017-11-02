/**

This VC subclasses AVPlayerViewController, which the online docs suggest you shouldn't do

Inline docs don't care as much?
**/

//TODO: refactor to not subclass AVPlayerViewController?
import UIKit
import AVKit

class PlayerViewController: AVPlayerViewController, AVPlayerViewControllerDelegate {
	var seekOperation: SeekOperation?
	var isSeekingEnabled = true
	var overlayView: PlayerOverlayView!;
	
	//TODO: clean up hacky unsafe pointerz
	var a = 0
	var b = 0
	var c = 0
	var selfContext:UnsafeMutableRawPointer
	var playerContext:UnsafeMutableRawPointer
	var playerItemContext:UnsafeMutableRawPointer

	override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
		self.selfContext = UnsafeMutableRawPointer(&a)
		self.playerContext = UnsafeMutableRawPointer(&b)
		self.playerItemContext = UnsafeMutableRawPointer(&c)
		super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//		self.isSkipForwardEnabled = false;
//		self.isSkipBackwardEnabled = false;
	}
	
	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		requiresLinearPlayback = false;
		skippingBehavior = .skipItem
		delegate = self
		self.overlayView = PlayerOverlayView().fromNibNamed("PlayerOverlayView")
		
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
	}
	
	func debugItem() {
		print("=============DEBUG ITEM==============")
		guard let item = self.player?.currentItem else { return }
		print(item)
		print("duration",item.duration.desc)
		print("asset", item.asset)
		print("tracks",item.tracks)
		if let _ = item.timedMetadata {
			print("timeMetadata \(item.timedMetadata!)")
		}
		print("loadedKeys",item.automaticallyLoadedAssetKeys)
		print("canFF",item.canPlayFastForward)
		print("canFR",item.canPlayFastReverse)
		print("forwardEndTime",item.forwardPlaybackEndTime.desc)
		print("reverseEndTime",item.reversePlaybackEndTime.desc)
		print("preferredForwardBufferDuration: \(item.preferredForwardBufferDuration)")
		for value in item.seekableTimeRanges {
			let tr = value.timeRangeValue
			print("-- seekableTimeRange:")
			CMTimeRangeShow(tr)
		}
		for value in item.loadedTimeRanges {
			let tr = value.timeRangeValue
			print("--- loadedTimeRanges:")
			CMTimeRangeShow(tr)
		}

		if item.currentDate() != nil {
			print("currentDate \(item.currentDate()!)")
		}
		print("currentTime",item.currentTime().desc)
		print("canUseNetworkResourcesForLiveStreamingWhilePaused", item.canUseNetworkResourcesForLiveStreamingWhilePaused)
		let beginTime = item.seekableTimeRanges.sorted(by: { (leftV, rightV) -> Bool in
			let left = leftV.timeRangeValue, right = rightV.timeRangeValue
			return left.start < right.start
		}).first
		let endTime = item.seekableTimeRanges.sorted(by: { (leftV, rightV) -> Bool in
			let left = leftV.timeRangeValue, right = rightV.timeRangeValue
			return left.end > right.end
		}).first
		
		print("beginTime: \(beginTime?.description ?? "")")
		print("endTime: \(endTime?.description ?? "")")

		print("externalMetadata",item.externalMetadata)
		
		
		print("--asset--")
		let asset = item.asset
		print("duration",asset.duration.desc)
		print("metadata",asset.metadata)
	}
	
	var once = false;
	func showIntro() {
		if once { return }
		once = true;
		UIView.animate(withDuration: 0.5, delay: 1, options:[], animations: {
			self.overlayView.visualEffectView.alpha = 1.0;
		})
		UIView.animate(withDuration: 0.5, delay: 3.5, animations: {
			self.overlayView.visualEffectView.alpha = 0.0;
		});

	}
	
	func seekBy(_ increment: Int) {
		if !isSeekingEnabled {
			return
		}
//		print("\(#function) \(increment)")
		guard let player = self.player else {
			return;
		}
		
		if( self.seekOperation == nil || !self.seekOperation!.active ) {
			//new seek op!
			self.seekOperation = SeekOperation(initialMediaTime: player.currentTime())
		}
		
		guard let seekOp = self.seekOperation else { return }
		
		guard let seekableTimeRanges = player.currentItem?.seekableTimeRanges.map({ $0.timeRangeValue }) else { return }
		

		let proposedSeekTime = seekOp.proposedSeekTime(withAdditionalSwipes: increment)
//		print("proposedSeekTime by \(seekOp.swipes+increment): \(proposedSeekTime.seconds)")
//		print("seekOp.target: \(seekOp.targetSeekTime.seconds)")

		var actualSeekTime: CMTime!
		var offsetText = ""

		//validate values and clamp to real starts/ends
		if proposedSeekTime < seekOp.initialMediaTime {
			guard let startTime = seekableTimeRanges.sorted(by: { $0.start < $1.start }).first?.start else {
				return
			}
//			print("startTime: \(startTime.seconds)")
			if proposedSeekTime < startTime {
				seekOp.swipe(0)
				actualSeekTime = startTime
				offsetText = "At start"
			}
			else {
				seekOp.swipe(increment)
				let s = abs(seekOp.offsetSeconds) % 60
				let m = abs(seekOp.offsetSeconds) / 60
				offsetText = String(format:"%@%0d:%02d", seekOp.offsetSeconds > 0 ? "+" : "-", m, s)
			}
		}
		else {
			guard let endTime = seekableTimeRanges.sorted(by: { $0.end > $1.end }).first?.end else {
				return
			}
//			print("endTime: \(endTime.seconds)")
			
			if proposedSeekTime > endTime {
				seekOp.swipe(0)
				actualSeekTime = endTime
				offsetText = "At end"
			}
			else {
				seekOp.swipe(increment)
				let s = abs(seekOp.offsetSeconds) % 60
				let m = abs(seekOp.offsetSeconds) / 60
				offsetText = String(format:"%@%0d:%02d", seekOp.offsetSeconds > 0 ? "+" : "-", m, s)
			}
		}
		
		actualSeekTime = actualSeekTime ?? seekOp.targetSeekTime

		self.overlayView.label.text = offsetText;
		
		let options: UIViewAnimationOptions = [.curveEaseOut, .beginFromCurrentState]
		self.overlayView.visualEffectView.isHidden = true
		UIView.animate(withDuration: 0.15, delay: 0,
		               options: options,
		               animations: {
										self.overlayView.label.alpha = 1.0;
		}, completion:nil)
		
		player.seek(to: actualSeekTime) { finished in
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
	
	@objc func handleSwipeLeft(_ gestureRecognizer: UISwipeGestureRecognizer) {
		seekBy(-1)
	}
	
	@objc func handleSwipeRight(_ gestureRecognizer: UISwipeGestureRecognizer) {
		seekBy(1)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	public func playerViewController(_ playerViewController: AVPlayerViewController, willResumePlaybackAfterUserNavigatedFrom oldTime: CMTime, to targetTime: CMTime) {
		//		print("scrubbed from \(oldTime.seconds) to \(targetTime.seconds)");
	}
	
	func playerViewController(_ playerViewController: AVPlayerViewController, willTransitionToVisibilityOfTransportBar visible: Bool, with coordinator: AVPlayerViewControllerAnimationCoordinator) {		
		print("transportBar visible: \(visible)")
		if visible {
			disableSeeking()
		}
		else {
			enableSeeking()
		}
	}
	
	func disableSeeking() {
		isSeekingEnabled = false
		seekOperation?.cancel()
	}
	
	func enableSeeking() {
		isSeekingEnabled = true
	}
	//MARK: - AVPlayerViewControllerDelegate
	
	func skipToNextItem(for playerViewController: AVPlayerViewController) {
		seekBy(1)
	}
	
	func skipToPreviousItem(for playerViewController: AVPlayerViewController) {
		seekBy(-1)
	}
	//mark: - player kvo
	
	deinit {
		removeObservers()
	}
	
	
	func removeObservers() {
		unobservePlayer(player)
		self.removeObserver(self, forKeyPath: #keyPath(player), context: selfContext)
	}
	
	func setupObservers() {
		self.addObserver(self, forKeyPath: #keyPath(player), options: [.initial, .new, .old], context:selfContext)
	}
	
	func observePlayer(_ player: AVPlayer?) {
		guard let player = player else { return }
		
		player.addObserver(self, forKeyPath: "status", options: [.initial, .new, .old], context: playerContext)
		player.addObserver(self, forKeyPath: "currentItem", options: [.initial, .new, .old], context: playerContext)
	}
	
	func unobservePlayer(_ player: AVPlayer? ){
		guard let player = player else { return }
		unobservePlayerItem(player.currentItem)
		player.removeObserver(self, forKeyPath: "status", context: playerContext)
		player.removeObserver(self, forKeyPath: "currentItem", context: playerContext)
	}
	
	func observePlayerItem(_ item: AVPlayerItem?) {
		guard let item = item else { return }
		item.canUseNetworkResourcesForLiveStreamingWhilePaused = true
		item.addObserver(self, forKeyPath: "duration", options: [.initial, .new, .old], context: playerItemContext)
	}
	
	func unobservePlayerItem(_ item: AVPlayerItem?) {
		guard let item = item else { return }
		item.removeObserver(self, forKeyPath: "duration", context: playerItemContext)
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
		
		if context == selfContext {
			unobservePlayer(change?[.oldKey] as? AVPlayer)
			observePlayer(change?[.newKey] as? AVPlayer)
		}
		else if context == playerContext {
			if keyPath == "status" {
				if let statusNumber = change?[.newKey] as? NSNumber {
					let newStatus = AVPlayerItemStatus(rawValue: statusNumber.intValue)!
					if newStatus == .readyToPlay {
						DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+2, execute: {
//							self.debugItem()
						})
						DispatchQueue.main.async {
							self.showIntro()
						}
					}
				}
			}
			else if keyPath == "currentItem" {
				unobservePlayerItem(change?[.oldKey] as? AVPlayerItem)
				observePlayerItem(change?[.newKey] as? AVPlayerItem)
			}
		}
		else if context == playerItemContext {
			//			guard let duration = change?[.newKey] as? CMTime else { return }
		}
	}
}

extension CMTime {
	var desc: String {
		var o = flags.contains(.valid) ? "valid" : "invalid"
		if flags.contains(.indefinite) { o.append(", indefinite") }
		if flags.contains(.negativeInfinity) { o.append(", -inf") }
		if flags.contains(.positiveInfinity) { o.append(", +inf") }
		let s = String(format:"%@, %.0f sec", o, seconds )
		return s;
	}
}

