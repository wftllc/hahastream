import UIKit

class LoginViewController: HahaViewController, UITextFieldDelegate {
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var activationCodeLabel: UILabel!
	@IBOutlet weak var errorLabel: UILabel!
	
	var interactor: LoginInteractor?
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imageView.layer.cornerRadius = 40;
		self.imageView.layer.masksToBounds = true;
		self.imageView.layer.shadowRadius = 20;
		self.imageView.layer.shadowColor = UIColor.black.cgColor;
		self.imageView.layer.shadowOpacity = 0.5;
		
		self.activationCodeLabel.layer.cornerRadius = 5
		self.activationCodeLabel.layer.masksToBounds = true;
		
		updateView(activationCode: nil, error: nil)

		interactor?.viewDidLoad()
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
//	func showLoading() {
//		self.activityIndicator.startAnimating();
//	}
//
//	func hideLoading() {
//		self.activityIndicator.stopAnimating();
//	}
	
	func updateView(activationCode: String?, error: String?) {
		if let code = activationCode {
			self.activityIndicator.stopAnimating()
			self.activationCodeLabel.text = code;
		}
		else {
			self.activityIndicator.startAnimating()
		}
		
		self.errorLabel.text = error
	}
	
}
