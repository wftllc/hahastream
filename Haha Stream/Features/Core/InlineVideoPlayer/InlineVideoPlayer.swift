import UIKit
import AVFoundation

class InlineVideoPlayer: NSObject {
	enum Error: Swift.Error {
		case alreadyLoaded
		case foundationError(error: Swift.Error?)
	}
	
	private let url: URL
	
	private var initialized = false
	private var readyBlock: (() -> Void)?
	private var failureBlock: ((InlineVideoPlayer.Error) -> Void)?
	private var progressBlock: ((Int) -> Void)?
	private var completionBlock: (() -> Void)?
	
	private var timeObserver: Any?
	private var observer: NSObjectProtocol?
	var player: AVPlayer?

	var playerItemObservation: NSKeyValueObservation?

	override var debugDescription: String {
		return (self.player?.currentItem?.asset as? AVURLAsset)?.url.absoluteString ?? "Player: No current player"
	}
	
	required init(url:URL) {
		self.url = url
	}
	
	func load(
		ready: (() -> Void)?,
		failure: ((InlineVideoPlayer.Error) -> Void)?,
		progress: ((Int) -> Void)?,
		completion: (() -> Void)?
		)
	{
		//we only support playing one video once.
		if initialized {
			failure?(.alreadyLoaded)
			return
		}
		
		self.readyBlock = ready
		self.failureBlock = failure
		self.progressBlock = progress
		self.completionBlock = completion
		
		let asset = AVURLAsset(url: url)
		let playerItem = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: ["tracks", "duration"])
		
		self.player = AVPlayer(playerItem: playerItem)
		self.player?.isMuted = true
		self.observer = NotificationCenter.default.addObserver(
			forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
			object: player?.currentItem,
			queue: nil) { [unowned self] _ in
				self.removeObservers()
				DispatchQueue.main.async {
					self.completionBlock?()
				}
		}
		
		self.playerItemObservation = playerItem.observe(\.status) { [weak self] object, change in
			print("\(object) got change \(change)")
			guard let status = self?.player?.currentItem?.status else { return }
			if status == .readyToPlay {
				let block = self?.readyBlock
				self?.readyBlock = nil
				DispatchQueue.main.async {
					block?()
				}
			}
			else if status == .failed {
				DispatchQueue.main.async {
					self?.failureBlock?(Error.foundationError(error: playerItem.error))
				}
			}
		}
	}
	
	private func removeObservers() {
		self.playerItemObservation = nil
		if let observer = self.observer {
			NotificationCenter.default.removeObserver(observer)
			self.observer = nil
		}
	}
	
	func play() {
		self.player?.play()
	}
	
	func stop() {
		self.player?.pause()
		removeObservers()
		self.player = nil
	}
	
	deinit {
		removeObservers()
		if let to = self.timeObserver {
			self.player?.removeTimeObserver(to)
		}
	}
	
}




