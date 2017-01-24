import UIKit

class LoginViewController: HahaViewController, UITextFieldDelegate {
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var textField: UITextField!
	
	@IBOutlet weak var signinButton: UIButton!
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	@IBOutlet weak var apiKeyDisplayLabel: UILabel!
	
	@IBOutlet var textfieldAccessoryView: UIView!
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imageView.layer.cornerRadius = 40;
		self.imageView.layer.masksToBounds = true;
		self.imageView.layer.shadowRadius = 20;
		self.imageView.layer.shadowColor = UIColor.black.cgColor;
		self.imageView.layer.shadowOpacity = 0.5;

		self.textField.text = AppProvider.apiKey;
		self.textField.inputAccessoryView = self.textfieldAccessoryView;
		self.apiKeyDisplayLabel.text = self.textField.text
	}
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		return [self.textField, self.signinButton];
	};
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func textfieldPrimaryActionTriggered(_ sender: Any) {
		if( self.textField.text!.lengthOfBytes(using: .utf8) >= 6 ) {
			submitAPIKey(self.textField.text!)
		}
	}

	@IBAction func textFieldEditingChanged(_ sender: UITextField) {
		self.apiKeyDisplayLabel.text = sender.text
	}
	
	func showLoading() {
		self.activityIndicator.startAnimating();
		self.textField.isEnabled = false;
		self.signinButton.isEnabled = false;
	}
	
	func hideLoading() {
		self.activityIndicator.stopAnimating();
		self.textField.isEnabled = true;
		self.signinButton.isEnabled = true;
	}
	
	func submitAPIKey(_ text: String) {
		if( text.lengthOfBytes(using: .utf8) >= 1 ) {
			showLoading();
			self.provider.apiKey = text;
			self.provider.getSports(success: { (sports) in
				self.hideLoading()
				AppProvider.apiKey = text
				self.appRouter.handleLoginComplete();
			}, apiError: { (error) in
				self.hideLoading()
				self.handleApiError(error);
			}, networkFailure: { (error) in
				self.hideLoading()
				self.handleNetworkError(error);
			})
		}
	}

	@IBAction func signinDidTap(_ sender: Any) {
		textField.becomeFirstResponder()
	}
	
	
}
