//
//  LoginInteractor.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/4/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import UIKit

class AccountInteractor: NSObject {
	let PollingInterval = 1.0
	weak var view: AccountViewController?
	let provider: HahaProvider
	let router: AppRouter?
	
	init(provider: HahaProvider, router: AppRouter) {
		self.provider = provider
		self.router = router
	}
	
	func viewDidLoad() {
	}
	
	func viewDidAppear() {
		self.refresh()
	}
	
	func viewDidTapDeactivate() {
		view?.showConfirmDeactivationDialog()
	}
	
	func viewDidConfirmDeactivation() {
		view?.showLoading(animated: true)
		self.provider.deactivateDevice(success: {
			self.view?.hideLoading(animated: false, completion: {
				self.router?.handleLogoutComplete()
				self.view?.showAlert(title: "Deactivated", message: "Press OK to Continue", onDismiss: {
					self.router?.gotoFirstScreen()
				})
			})
		}, apiError: self.view!.apiErrorClosure, networkFailure: self.view!.networkFailureClosure)
	}
	func refresh() {
		print("\(#function)")
		self.provider.getDeviceActivationStatus(success: { (status) in
			self.view?.updateView(isActivated: status.isActivated)
		}, apiError: self.view!.apiErrorClosure, networkFailure: self.view!.networkFailureClosure)
	}
	
}
