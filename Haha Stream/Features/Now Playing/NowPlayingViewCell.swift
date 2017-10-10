import UIKit
import CoreGraphics

class NowPlayingViewCell: UICollectionViewCell {
	
	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var bottomView: UIView!
	@IBOutlet weak var bottomVisualEffectView: UIVisualEffectView!
	@IBOutlet weak var visualEffectView: UIVisualEffectView!
	@IBOutlet weak var innerVisualEffectView: UIVisualEffectView!
//	@IBOutlet weak var homeTeamLabel: UILabel!
//	@IBOutlet weak var awayTeamLabel: UILabel!
	@IBOutlet weak var awayImageView: UIImageView!
	@IBOutlet weak var homeImageView: UIImageView!
	@IBOutlet weak var singleImageView: UIImageView!
//	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	
	var timer: Timer?;
	
	var horizontalMotionEffect: UIInterpolatingMotionEffect!
	
	override func awakeFromNib() {
		super.awakeFromNib();
		self.visualEffectView.layer.cornerRadius = 7.0;
		self.visualEffectView.layer.masksToBounds = true;
		
		self.topView.layer.shadowRadius = 12;
		self.topView.layer.shadowOpacity = 0.25;
		self.topView.layer.shadowOffset = CGSize(width:0, height:5);

		
//
		self.horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		self.horizontalMotionEffect.minimumRelativeValue = -6
		self.horizontalMotionEffect.maximumRelativeValue = 6

		self.clearFocused()

		
//		let verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
//		verticalMotionEffect.minimumRelativeValue = -3
//		verticalMotionEffect.maximumRelativeValue = 3
//		self.contentView.addMotionEffect(verticalMotionEffect)
//		self.contentView.backgroundColor = UIColor.white.withAlphaComponent(1.0);
//		self.showFocused();
//		self.homeImageView.adjustsImageWhenAncestorFocused = true;
//		self.awayImageView.adjustsImageWhenAncestorFocused = true;
//		self.view.clipToBounds = false;
	}

	func updateTimeLabel(withDate date: Date) {
		if( date.timeIntervalSinceNow < -4.0*60*60 ) {
			timeLabel.text = "Complete";
		}
		else {
//			timeLabel.text = "Now Playing (\(date.elapsedTimeString))";
			timeLabel.text = date.elapsedTimeString;
		}
	}
	func startAnimating(date: Date) {
		if( self.timer != nil ) {
			return;
		}
		let options: UIViewAnimationOptions = [UIViewAnimationOptions.curveEaseInOut, UIViewAnimationOptions.transitionCrossDissolve];
		self.timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { (timer) in
			UIView.transition(with: self.timeLabel, duration: 0.25, options: options, animations: {
				self.updateTimeLabel(withDate: date)
			})
		}
		self.timer?.fire();
	}

	func stopAnimating() {
		self.timer?.invalidate();
		self.timer = nil;
	}
	
	override func prepareForReuse() {
		stopAnimating()
		super.prepareForReuse()
	}
	func showFocused() {
		self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
//		self.topView.layer.shadowRadius = 12;
//		self.topView.layer.shadowOffset = CGSize(width:0, height:15);
		self.innerVisualEffectView.effect = UIBlurEffect(style: UIBlurEffectStyle.light);
		self.bottomVisualEffectView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffectStyle.dark));
		self.contentView.addMotionEffect(horizontalMotionEffect!)
	}
	
	func clearFocused() {
		self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		self.innerVisualEffectView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffectStyle.light));
		self.bottomVisualEffectView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffectStyle.regular));
		self.contentView.removeMotionEffect(horizontalMotionEffect)
	}
	
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//		print("viewcell.didUpdateFocus from", context.previouslyFocusedView, "to", context.nextFocusedView);
		if let cell = context.nextFocusedView as? NowPlayingViewCell {
			coordinator.addCoordinatedAnimations({
				cell.showFocused()
			})
		}
		if let cell = context.previouslyFocusedView as? NowPlayingViewCell {
			coordinator.addCoordinatedAnimations({
				cell.clearFocused();
			})
		}
		
	}
}
