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
	}

	func startTimer() {
		self.timer?.invalidate()
		self.timer = Timer.scheduledTimer(withTimeInterval: RefreshTimeInterval, repeats: true) { (timer) in
			self.refreshData()
		};
	}
	
	func refreshData() {
		self.view?.showLoading(animated: true);
		self.provider.getNowPlaying(success: { (items) in
			self.view?.hideLoading(animated: true)
			self.view?.updateView(items: items)
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}

	func viewDidSelect(item: NowPlayingItem) {
		if let game = item.game {
			view?.selectGame(game);
		}
		else {
			selectChannel(item.channel!);
		}
	}
	
	
	
	func selectChannel(_ channel: Channel) {
		view?.showLoading(animated: true);
		
		provider.getStream(channel: channel, success: { (stream) in
			self.view?.hideLoading(animated: true, completion: {
				if let stream = stream {
					//					self.playURL(stream.url!)
				}
				else {
					self.view?.showAlert(title: "No Stream", message: "Couldn't find stream for \(channel.title)");
				}
			});
		}, apiError: self.view!.apiErrorClosure,
		   networkFailure: self.view!.networkFailureClosure
		)
	}
}
