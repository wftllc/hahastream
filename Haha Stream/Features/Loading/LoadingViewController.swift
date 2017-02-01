import UIKit
import AVKit

class LoadingViewController: HahaViewController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override func playURL(_ url: URL) {
		print("playURL");
		let parentVC = self.presentingViewController;
		self.dismiss(animated: false) {
			// Create an AVPlayer, passing it the HTTP Live Streaming URL.
			let player = AVPlayer(url: url)
			
			// Create a new AVPlayerViewController and pass it a reference to the player.
			let controller = PlayerViewController()
			controller.player = player
			
			// Modally present the player and call the player's play() method when complete.
			parentVC?.present(controller, animated: true) {
				player.play()
			}
		}
	}
	
	override func onStreamChoiceCanceled(){
		self.dismiss(animated: true, completion: nil);
	}
	
	override func showLoading(animated: Bool) {
		//do nothing!
	}
	
	override func hideLoading(animated: Bool, completion: (() -> Void)?) {
		completion?()
		//do nothing!
	}
	
	override func showAlert(title: String, message: String) {
		let parentVC = self.presentingViewController;
		
		self.dismiss(animated: true) {
			parentVC?.showAlert(title: title, message: message)
		}
	}

	override func showLoginAlert(message: String) {
		let parentVC = self.presentingViewController;
		
		self.dismiss(animated: true) {
			parentVC?.showLoginAlert(message: message)
		}
	}

	
}
