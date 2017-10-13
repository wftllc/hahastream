//
//  NowPlayingInteractiveVideoInteractor.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/13/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import Foundation
/*
class NowPlayingInlineVideoInteractor: NowPlayingInteractor {

	override func viewWillDisappear(_ animated: Bool) {
		self.stopVideo()
			super.viewWillDisappear(animated)
	}
	func viewDidHighlight(item: NowPlayingItem) {
		guard let game = item.game else {
			return
		}
		//		provider.getStreams(game: game, success: { (streams) in
		//			guard let stream = streams.first else { return }
		//			self.provider.getURLForStream(stream, game: game, success: { (url) in
		//				self.previewVideo(url: url.url)
		//			}, apiError: { (_) in
		//
		//			}, networkFailure: { (_) in
		//
		//			})
		//		}, apiError: { _ in }, networkFailure: { _ in })
		
		//		provider.getStreams(sport: game.sport, game: game, success: { (streams) in
		//			if let stream = streams {
		//
		//			}
		//			previewVideo(url: URL(string: "http://lavenberg.com/test/demo.mp4")!)
		//		});
		//
	}
	
	func viewDidUnhighlight(item: NowPlayingItem) {
		stopVideo()
	}
	private func previewVideo(url: URL) {
		print("\(#function) \(url.absoluteString))")
		self.videoPlayer = InlineVideoPlayer(url: url)
		videoPlayer?.load( ready: { [unowned self] in
			self.videoPlayer?.play()
			self.view?.showVideo(player: self.videoPlayer!.player!)
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
		self.view?.hideVideo()
	}
}
*/
