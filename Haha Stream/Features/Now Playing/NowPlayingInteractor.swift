//
//  NowPlayingInteractor.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/4/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import UIKit

class NowPlayingInteractor: NSObject {
	let RefreshTimeInterval: TimeInterval = 300;
	var timer: Timer?;
	weak var view: NowPlayingViewController?
	let provider: HahaProvider
	let router: AppRouter?
	var videoPlayer: InlineVideoPlayer?
	
	init(provider: HahaProvider, router: AppRouter) {
		self.provider = provider
		self.router = router
	}
	
	
	func viewDidLoad() {
		refreshData();
	}
	
	func viewWillAppear(_ animated: Bool) {
		refreshData()
		startTimer()
	}
	
	func viewWillDisappear(_ animated: Bool) {
		self.timer?.invalidate();
		self.stopVideo()
	}
	
	func startTimer() {
		self.timer?.invalidate()
		self.timer = Timer.scheduledTimer(withTimeInterval: RefreshTimeInterval, repeats: true) { (timer) in
			self.refreshData()
		};
	}
	
	func refreshData(showLoading: Bool = false) {
		if showLoading {
			self.view?.showLoading(animated: true);
		}
		self.provider.getNowPlaying(success: { (sections) in
			if showLoading {
				self.view?.hideLoading(animated: true, completion: nil)
			}
			self.view?.updateView(sections: sections)
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}
	
	
	func viewDidHighlight(item: NowPlayingItem) {
		return;
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
		return;
		stopVideo()
	}
	
	func viewDidSelect(item: NowPlayingItem) {
		if let game = item.game {
			selectGame(game);
		}
		else {
			selectChannel(item.channel!);
		}
	}
	
	func viewDidSelect(stream: Stream, game: Game) {
		view?.showLoading(animated: true)
		self.play(stream: stream, inGame: game)
	}

	func selectGame(_ game: Game) {
		view?.showLoading(animated: true)
		provider.getStreams(game: game, success: { (streams) in
			if streams.count == 1 {
				self.play(stream: streams[0], inGame: game)
			}
			else {
				self.view?.hideLoading(animated: true) {
					self.view?.showStreamChoiceAlert(game: game, streams: streams)
				}
			}
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}

	func selectChannel(_ channel: Channel) {
		view?.showLoading(animated: true);
		provider.getStream(channel: channel, success: { (stream) in
			self.play(stream: stream, inChannel: channel)
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}

	func play(stream: Stream, inGame game: Game) {
		self.provider.getStreamURL(forStream: stream, inGame: game, success: { (streamURL) in
			self.view?.hideLoading(animated: false) {
				self.view?.playURL(streamURL.url);
			}
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}

	func play(stream: Stream, inChannel channel: Channel) {
		self.provider.getStreamURL(forStream: stream, inChannel: channel, success: { (streamURL) in
			self.view?.hideLoading(animated: false) {
				self.view?.playURL(streamURL.url);
			}
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}
	
	private func previewVideo(url: URL) {
		return;
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
		return;
		print("\(#function)")
		self.videoPlayer?.stop()
		self.videoPlayer = nil
		self.view?.hideVideo()
	}
	
}
