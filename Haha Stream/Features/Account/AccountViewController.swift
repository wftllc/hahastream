import UIKit

class AccountViewController: HahaViewController, UITextFieldDelegate {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var errorLabel: UILabel!
	
	@IBOutlet weak var deviceStatusLabel: UILabel!
	var interactor: AccountInteractor?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imageView.layer.cornerRadius = 40;
		self.imageView.layer.masksToBounds = true;
		self.imageView.layer.shadowRadius = 20;
		self.imageView.layer.shadowColor = UIColor.black.cgColor;
		self.imageView.layer.shadowOpacity = 0.5;
		
		updateView(isActivated: nil)

		interactor?.viewDidLoad()
	}
	
	override func viewDidAppear(_ animated: Bool) {
		interactor?.viewDidAppear()
		super.viewDidAppear(animated)
	}
//	func showLoading() {
//		self.activityIndicator.startAnimating();
//	}
//
//	func hideLoading() {
//		self.activityIndicator.stopAnimating();
//	}
	
	@IBAction func deactivateDidTap(_ sender: Any) {
		interactor?.viewDidTapDeactivate()
	}
	func updateView(isActivated: Bool?) {
		if let isActivated = isActivated {
			self.deviceStatusLabel.text = isActivated ? "Activated" : "Not Activated"
			self.activityIndicator.stopAnimating()
		}
		else {
			self.deviceStatusLabel.text = ""
			self.activityIndicator.startAnimating()
		}
	}
	
	func showConfirmDeactivationDialog() {
		self.showAlert(title: "Deactivate and Logout?", message: "This will deactivate your device and log you out.", okTitle: "Log Out") {
			self.interactor?.viewDidConfirmDeactivation()
		}
	}
	
}
