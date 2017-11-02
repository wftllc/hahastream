import UIKit
import AVKit
import Foundation


protocol ContentListInlineVideoView: ContentListView {
	var inlineInteractor: ContentListInlineVideoInteractor? { get }
	func showVideo(player: AVPlayer)
	func hideVideo()
}

class ContentListInlineVideoViewController: ContentListViewController, ContentListInlineVideoView {
	var inlineInteractor: ContentListInlineVideoInteractor? { get {
		return self.interactorStorage as? ContentListInlineVideoInteractor
		}
	}
	
	override func viewDidLoad() {
		super.viewDidLoad()		
		self.inlinePlayerContainerView.layer.shadowRadius = 12;
		self.inlinePlayerContainerView.layer.shadowOpacity = 0.75;
		self.inlinePlayerContainerView.layer.shadowOffset = CGSize(width:0, height:10);
		self.inlinePlayerContainerView.layer.masksToBounds = false
//		self.inlinePlayerContainerView.addFo
	}
	
	//MARK: - IBActions
	
	//MARK: - Focus

//	override func shouldUpdateFocus(in context: UIFocusUpdateContext) -> Bool {
//		let result = super.shouldUpdateFocus(in: context)
//		print("\(#function), \(context)\n\t=>\(result)")
//		return result
//	}
	//MARK: - UICollectionViewDelegate
	
	func collectionView(_ collectionView: UICollectionView, didUpdateFocusIn context: UICollectionViewFocusUpdateContext, with coordinator: UIFocusAnimationCoordinator) {
		if let cell = context.previouslyFocusedView as? ContentListViewCell,
			let indexPath = collectionView.indexPath(for: cell) {
			guard let item = self.contentList?.item(atIndexPath: indexPath) else {
				return
			}
			inlineInteractor?.viewDidUnhighlight(item: item)
		}
		if let cell = context.nextFocusedView as? ContentListViewCell,
			let indexPath = collectionView.indexPath(for: cell) {
			guard let item = self.contentList?.item(atIndexPath: indexPath) else {
				return
			}
			inlineInteractor?.viewDidHighlight(item: item)
		}
	}
	

	func collectionView(_ collectionView: UICollectionView, didHighlightItemAt indexPath: IndexPath) {
		guard let item = self.contentList?.item(atIndexPath: indexPath) else {
			return
		}
		inlineInteractor?.viewDidHighlight(item: item)
	}
	
	func collectionView(_ collectionView: UICollectionView, didUnhighlightItemAt indexPath: IndexPath) {
		guard let item = self.contentList?.item(atIndexPath: indexPath) else {
			return
		}
		inlineInteractor?.viewDidUnhighlight(item: item)
	}

	//MARK: - Video
	let VideoFadeAnimationDuration = 0.15
	var playerLayerObservationContext: UnsafeMutableRawPointer?
	var isObservingPlayerLayer = false
	
	func showVideo(player: AVPlayer) {
		print("\(#function)")
		inlineVideoPlayerView.player = player
		addPlayerLayerObserver()
	}
	
	func hideVideo() {
		UIView.animate(withDuration: self.VideoFadeAnimationDuration, animations: {
			self.inlinePlayerContainerView.alpha = 0.0
		}, completion: { _ in
			self.removePlayerLayerObserver()
			self.inlineVideoPlayerView.player = nil
		})
	}
	
	//observe player readiness
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context != self.playerLayerObservationContext {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}
		let ready = self.inlineVideoPlayerView.playerLayer.isReadyForDisplay
		print("\(#function), \(ready)")
		if ready {
			self.removePlayerLayerObserver()
			UIView.animate(withDuration: self.VideoFadeAnimationDuration, animations: {
				self.inlinePlayerContainerView.alpha = 1.0
			}, completion: { _ in
				self.setNeedsFocusUpdate()
			})
		}
	}
	
	private func addPlayerLayerObserver() {
		if isObservingPlayerLayer {
			return
		}
		isObservingPlayerLayer = true
		self.inlineVideoPlayerView.playerLayer.addObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), options: [.new, .initial], context: self.playerLayerObservationContext)
	}

	private func removePlayerLayerObserver() {
		if !isObservingPlayerLayer {
			return
		}
		isObservingPlayerLayer = false
		self.inlineVideoPlayerView.playerLayer.removeObserver(self, forKeyPath: #keyPath(AVPlayerLayer.isReadyForDisplay), context: playerLayerObservationContext)
	}

}

