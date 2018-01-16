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
		print("\(#function); identifier: \(UIDevice.current.identifierForVendor!.uuidString)")
		guard let ident = UIDevice.current.identifierForVendor?.uuidString else {
			let error = "identifierForVendor is nil; trying again..."
			print("\(#function); \(error)")
			view?.updateView(activationCode: nil, error: error)
			DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+self.PollingInterval) {
				self.pollForRegistrationKey()
			}
			return;
		}
		self.provider.getDeviceRegistrationKey(success: { [weak self] (deviceKey) in
			print("getDeviceRegistrationKey() success: \(deviceKey?.description)")
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
				print("getDeviceRegistrationKey() apiError: \(error)")
				self?.view?.updateView(activationCode: nil, error: "We're having trouble fetching your code (api error). Keep waiting, or contact Hehestreams support.")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self?.PollingInterval ?? 0)) {
					self?.pollForRegistrationKey()
				}
			}, networkFailure: { [weak self] (error) in
				print("getDeviceRegistrationKey() networkFailure: \(error)")
				self?.view?.updateView(activationCode: nil, error: "We're having trouble fetching your code (network error). Keep waiting, or contact Hehestreams support.")
				DispatchQueue.main.asyncAfter(deadline: DispatchTime.now()+(self?.PollingInterval ?? 0)) {
					self?.pollForRegistrationKey()
				}
		})
	}
	
	func pollForActivation(deviceKey: DeviceKey) {
		print("\(#function) \(deviceKey.description)")
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
