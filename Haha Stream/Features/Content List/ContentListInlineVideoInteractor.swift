import Foundation

protocol ContentListInlineVideoInteractor: ContentListInteractor {
	weak var inlineView: ContentListInlineVideoView? { get }
	func viewDidHighlight(item: ContentItem)
	func viewDidUnhighlight(item: ContentItem)
	func viewDidTapInlinePreview()
}

class ContentListInlineVideoInteractorImpl: ContentListInteractorImpl, ContentListInlineVideoInteractor  {
	var inlineView: ContentListInlineVideoView? { get {
		return self.viewStorage as? ContentListInlineVideoView
		}
	}

	var videoPlayer: InlineVideoPlayer?
	var highlightedGame: Game?
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		self.stopVideo()
	}

	func viewDidHighlight(item: ContentItem) {
		guard let game = item.game else {
			return
		}
		highlightedGame = game
		provider.getStreams(game: game, success: { [weak self] (streams) in
			self?.provider.getStreamURL(forStream: streams[0], inGame: game, success: { (streamURL) in
				if self?.highlightedGame == game {
					self?.previewVideo(url: streamURL.url)
				}
			}, apiError: { _ in },
				 networkFailure: { _ in }
			)
		}, apiError: { _ in },
		   networkFailure: { _ in }
		)
	}
	
	func viewDidUnhighlight(item: ContentItem) {
		stopVideo()
	}
	
	func viewDidTapInlinePreview() {
	}

	private func previewVideo(url: URL) {
		print("\(#function) \(url.absoluteString))")
		self.videoPlayer = InlineVideoPlayer(url: url)
		videoPlayer?.load( ready: { [unowned self] in
			self.videoPlayer?.play()
			self.inlineView?.showVideo(player: self.videoPlayer!.player!)
			}, failure: { [unowned self] error in
				print("video load failure: \(error)")
				self.stopVideo()
			}, progress: nil,
			   completion: { [unowned self] in
					self.stopVideo()
		})
	}
	
	private func stopVideo() {
		print("\(#function)")
		self.videoPlayer?.stop()
		self.videoPlayer = nil
		self.inlineView?.hideVideo()
	}
}

