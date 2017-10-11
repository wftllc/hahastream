//
//  LoginInteractor.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/4/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import UIKit

class LoginInteractor: NSObject {
	let PollingInterval = 1.0
	weak var view: LoginViewController?
	let provider: HahaProvider
	let router: AppRouter?
	
	init(provider: HahaProvider, router: AppRouter) {
		self.provider = provider
		self.router = router
	}
	
	
	func viewDidLoad() {
		self.pollForRegistrationKey()
	}
	
	//flow is getDeviceKey (returns activation code)
	//	=> user submits to site
	//	=> poll on activateWithKey (returns api key)
	//	=> logged in, store api key

	func pollForRegistrationKey() {
		print("\(#function)")
		self.provider.getDeviceRegistrationKey(success: { [weak self] (deviceKey) in
			if let deviceKey = deviceKey {
				self?.view?.updateView(activationCode: deviceKey.key, error: nil)
				self?.pollForActivation(deviceKey: deviceKey)
			}
			else {
				self?.view?.updateView(activationCode: nil, error: "We're having trouble fetching your code. Keep waiting, or contact Hehestreams support.")
				
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self?.PollingInterval ?? 0)) {
					self?.pollForRegistrationKey()
				}
			}
			}, apiError: { [weak self] (error) in
				self?.view?.updateView(activationCode: nil, error: "We're having trouble fetching your code (api error). Keep waiting, or contact Hehestreams support.")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self?.PollingInterval ?? 0)) {
					self?.pollForRegistrationKey()
				}
			}, networkFailure: { [weak self] (error) in
				self?.view?.updateView(activationCode: nil, error: "We're having trouble fetching your code (network error). Keep waiting, or contact Hehestreams support.")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self?.PollingInterval ?? 0)) {
					self?.pollForRegistrationKey()
				}
		})
	}
	
	func pollForActivation(deviceKey: DeviceKey) {
		print("\(#function)")
		self.provider.activateDevice(deviceKey: deviceKey, success: { [weak self] activation in
			print("activation \(activation.description)")
			self?.completeActivation(activation)
		}, apiError: { [weak self] (error) in
				print("api error \(error)")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self?.PollingInterval ?? 0)) {
					self?.pollForActivation(deviceKey: deviceKey)
				}
		}, networkFailure: { [weak self] (error) in
			print("network error \(error)")
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self?.PollingInterval ?? 0)) {
				self?.pollForActivation(deviceKey: deviceKey)
			}
		})
	}
	
	func completeActivation(_ activation: DeviceActivation) {
		self.router?.handleLoginComplete(withActivation: activation)
	}
	
	
}
