import UIKit
import CoreGraphics
import Kingfisher

class ContentListViewCell: UICollectionViewCell {
	static var timeFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.current;
		df.dateStyle = .none;
		df.timeStyle = .short;
		return df;
	}()
	
	static var dateFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.current;
		df.setLocalizedDateFormatFromTemplate("EEE, dMM")
//		df.dateStyle = .short;
//		df.timeStyle = .none;
		return df;
	}()

	@IBOutlet weak var topView: UIView!
	@IBOutlet weak var bottomView: UIView!
	@IBOutlet weak var bottomVisualEffectView: UIVisualEffectView!
	@IBOutlet weak var visualEffectView: UIVisualEffectView!
	@IBOutlet weak var innerVisualEffectView: UIVisualEffectView!
//	@IBOutlet weak var homeTeamLabel: UILabel!
//	@IBOutlet weak var awayTeamLabel: UILabel!
	@IBOutlet weak var awayImageView: UIImageView!
	@IBOutlet weak var homeImageView: UIImageView!
	@IBOutlet weak var sportImageView: UIImageView!
	@IBOutlet weak var singleImageView: UIImageView!
//	@IBOutlet weak var statusLabel: UILabel!
	@IBOutlet weak var timeLabel: UILabel!
	@IBOutlet weak var titleLabel: UILabel!
	@IBOutlet weak var sportLabel: UILabel!	
	@IBOutlet weak var atLabel: UILabel!
	@IBOutlet weak var readyLabel: UILabel!
	@IBOutlet weak var focusedDateLabel: UILabel!
	
	var timer: Timer?;
	var shouldCancelAnimateLabels: Bool = false
	var horizontalMotionEffect: UIInterpolatingMotionEffect!
	var verticalMotionEffect: UIInterpolatingMotionEffect!

	override func awakeFromNib() {
		super.awakeFromNib();
		self.visualEffectView.layer.cornerRadius = 7.0;
		self.visualEffectView.layer.masksToBounds = true;
		
		self.topView.layer.shadowRadius = 12;
		self.topView.layer.shadowOpacity = 0.25;
		self.topView.layer.shadowOffset = CGSize(width:0, height:5);

		self.horizontalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.x", type: .tiltAlongHorizontalAxis)
		self.horizontalMotionEffect.minimumRelativeValue = -6
		self.horizontalMotionEffect.maximumRelativeValue = 6

		
		self.verticalMotionEffect = UIInterpolatingMotionEffect(keyPath: "center.y", type: .tiltAlongVerticalAxis)
		verticalMotionEffect.minimumRelativeValue = -3
		verticalMotionEffect.maximumRelativeValue = 3

		self.clearFocused()

		
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
		self.contentView.addMotionEffect(horizontalMotionEffect)
		self.contentView.addMotionEffect(verticalMotionEffect)

//		if !self.focusedDateLabel.isHidden {
//			self.focusedDateLabel.alpha = 1.0
//			self.timeLabel.alpha = 0.0
//			self.readyLabel.alpha = 0.0
//		}
	}
	
	func clearFocused() {
		self.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
		self.innerVisualEffectView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffectStyle.light));
		self.bottomVisualEffectView.effect = UIVibrancyEffect(blurEffect: UIBlurEffect(style: UIBlurEffectStyle.regular));
		self.contentView.removeMotionEffect(horizontalMotionEffect)
		self.contentView.removeMotionEffect(verticalMotionEffect)
//		self.focusedDateLabel.alpha = 0.0
//		self.timeLabel.alpha = 1.0
//		self.readyLabel.alpha = 1.0
	}
	
	func update(withContentItem item: ContentItem, inSection section: ContentList.Section) {
		if let game = item.game {
			update(withGame: game, inSection: section)
		}
		else if let channel = item.channel {
			update(withChannel: channel, inSection: section)
		}
	}
	
	func update(withGame game: Game, inSection section: ContentList.Section) {
		//hehestreams.com/images/sports/NBA.png hehestreams.com/images/teams/nba/CLE.png
		let baseURI = "http://hehestreams.com/images/teams/\(game.sport.name.lowercased())"
		let placeholder = UIImage(named: "sport-placeholder")
		if let team = game.homeTeam.abbreviation?.uppercased(), let url = URL(string: "\(baseURI)/\(team).png") {
			homeImageView.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.2))])
		}
		else {
			homeImageView.image = placeholder
		}

		if let team = game.awayTeam.abbreviation?.uppercased(), let url = URL(string: "\(baseURI)/\(team).png") {
			awayImageView.kf.setImage(with: url, placeholder: placeholder, options: [.transition(.fade(0.2))])
		}
		else {
			awayImageView.image = placeholder
		}
		
		updateSportImage(withSport: game.sport)
		
		let away = game.awayTeam.abbreviation ?? String((game.awayTeam.name ?? "???").prefix(3))
		let home = game.homeTeam.abbreviation ?? String((game.homeTeam.name ?? "???").prefix(3))
		titleLabel.text = "\(away) @ \(home)"
		sportLabel.text = game.sport.name
		focusedDateLabel.alpha = 0.0
		atLabel.isHidden = false
		if section == .nowPlaying {
			updateTimeLabel(withDate: game.startDate);
			startAnimating(date: game.startDate)
			readyLabel.isHidden = true
			focusedDateLabel.isHidden = false
			focusedDateLabel.text = "Now Playing"
			timeLabel.tintColor = readyLabel.tintColor
		}
		else if section == .upcoming {
			if game.startDate.isToday {
				readyLabel.isHidden = false
				focusedDateLabel.isHidden = false
				timeLabel.tintColor = nil
				timeLabel.text = type(of: self).timeFormatter.string(from: game.startDate);
				readyLabel.text = type(of: self).timeFormatter.string(from: game.readyDate);
				focusedDateLabel.text = "Ready at \(type(of: self).timeFormatter.string(from: game.readyDate))"
			}
			else {
				readyLabel.isHidden = true
				focusedDateLabel.isHidden = true
				timeLabel.tintColor = nil
				timeLabel.text = type(of: self).dateFormatter.string(from: game.startDate);
//				readyLabel.text = type(of: self).timeFormatter.string(from: game.readyDate);
//				focusedDateLabel.text = "Ready at \(type(of: self).timeFormatter.string(from: game.readyDate))"
			}
		}
		else {
			timeLabel.text = ""
			timeLabel.tintColor = nil
			readyLabel.isHidden = true
			focusedDateLabel.isHidden = true
			
		}
	}
	
	private func updateSportImage(withSport sport: Sport?) {
		//hehestreams.com/images/sports/NBA.png hehestreams.com/images/teams/nba/CLE.png

		if let sport = sport, let url = URL(string: "http://hehestreams.com/images/sports/\(sport.name.uppercased()).png") {
			let processor = ResizingImageProcessor(referenceSize: CGSize(width: 50, height: 50), mode: .aspectFit)
			sportImageView.kf.setImage(with: url, options: [.processor(processor)]) {
				(image, error, cacheType, imageUrl) in
				guard let image = image else { return }
				let margin: CGFloat = 8
				self.sportImageView.frame = CGRect(x: self.topView.bounds.size.width-image.size.width-margin,
				                                   y: self.topView.bounds.size.height-image.size.height-margin,
				                                   width: image.size.width,
				                                   height: image.size.height)
			}
		}
		else {
			sportImageView.image = nil
		}
	}
	
	func update(withChannel channel: Channel, inSection section: ContentList.Section) {
		titleLabel.text = channel.title
		timeLabel.text = nil;
		homeImageView.image = nil
		awayImageView.image = nil
		sportLabel.text = channel.sport?.name ?? ""
		atLabel.isHidden = true
		readyLabel.isHidden = true
		focusedDateLabel.isHidden = true
		
		updateSportImage(withSport: channel.sport)
	}
/*
label animating is not working well -- it keeps animating after leavint the cell
*/
//	func animateLabels(toggle: Bool) {
//		if self.shouldCancelAnimateLabels {
//			self.shouldCancelAnimateLabels = false
//			return
//		}
//		UIView.animate(withDuration: 0.6, delay: 3.0, options: [.beginFromCurrentState], animations: {
//			self.focusedDateLabel.alpha = toggle ? 0.0 : 1.0
//			self.timeLabel.alpha = toggle ? 1.0 : 0.0
//		}) { (complete) in
////			print("\(#function) complete \(complete)")
//			if complete && !self.shouldCancelAnimateLabels {
//				self.animateLabels(toggle: !toggle)
//			}
//			self.shouldCancelAnimateLabels = false
//		}
//	}
	
//	func cancelAnimateLabels() {
//		self.shouldCancelAnimateLabels = true
//		self.layer.removeAllAnimations()
//	}
	
	
	override func didUpdateFocus(in context: UIFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
//		print("viewdidUpdateFocus from", context.previouslyFocusedView, "to", context.nextFocusedView);
		if let cell = context.nextFocusedView as? ContentListViewCell {
			coordinator.addCoordinatedAnimations({
				cell.showFocused()
			}, completion: {
//				animateLabels(toggle: true)
			})
		}
		if let cell = context.previouslyFocusedView as? ContentListViewCell {
//			cancelAnimateLabels()
			coordinator.addCoordinatedAnimations({
				cell.clearFocused();
			}, completion: {
			})
		}
		
	}
}
