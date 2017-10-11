//
//  InlineVideoPlayer.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/10/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

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
	
	private var isObservingPlayerItem = false
	private var a = 0 //sorry about this haxx
	private var playerItemObservationContext:UnsafeMutableRawPointer
	private var timeObserver: Any?
	private var observer: NSObjectProtocol?
	var player: AVPlayer?
	
	override var debugDescription: String {
		return (self.player?.currentItem?.asset as? AVURLAsset)?.url.absoluteString ?? "Player: No current player"
	}
	
	required init(url:URL) {
		self.url = url
		self.playerItemObservationContext = UnsafeMutableRawPointer(&a)
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
		
		isObservingPlayerItem = true
		playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new, .initial], context: self.playerItemObservationContext)
	}
	
	private func removeObservers() {
		if let playerItem = self.player?.currentItem, isObservingPlayerItem {
			isObservingPlayerItem = false
			playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), context: playerItemObservationContext)
		}
		if let observer = self.observer {
			NotificationCenter.default.removeObserver(observer)
			self.observer = nil
		}
		
	}
	override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
		if context != playerItemObservationContext {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}
		
		guard let playerItem = self.player?.currentItem else {
			return
		}
		
		let status = playerItem.status
		
		print("InlineVideoPlayer.\(status.rawValue)")
		if status == .readyToPlay {
			let block = self.readyBlock
			self.readyBlock = nil
			DispatchQueue.main.async {
				block?()
			}
		}
		else if status == .failed {
			DispatchQueue.main.async {
				self.failureBlock?(Error.foundationError(error: playerItem.error))
			}
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




