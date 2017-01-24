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
	
	
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}

