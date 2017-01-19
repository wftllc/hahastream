import UIKit

class LoginViewController: UIViewController {
	
	public var provider: HahaProvider!;
	
	@IBOutlet weak var imageView: UIImageView!
	@IBOutlet weak var textField: UITextField!
	
	@IBOutlet weak var signinButton: UIButton!
	
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.imageView.layer.cornerRadius = 40;
		self.imageView.layer.masksToBounds = true;
		self.imageView.layer.shadowRadius = 20;
		self.imageView.layer.shadowColor = UIColor.black.cgColor;
		self.imageView.layer.shadowOpacity = 0.5;

		self.textField.text = AppProvider.apiKey;
	}
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		return [self.textField, self.signinButton];
	};
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	@IBAction func textfieldPrimaryActionTriggered(_ sender: Any) {
		print("textfieldPrimaryActionTriggered");
		if( self.textField.text!.lengthOfBytes(using: .utf8) >= 6 ) {
			
		}
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
		
	@IBAction func signinDidTap(_ sender: Any) {
		print("signinDidTap");
		guard let text = self.textField.text else { return }
		if( text.lengthOfBytes(using: .utf8) >= 1 ) {
			showLoading();
			self.provider.apiKey = text;
			self.provider.getSports(success: { (sports) in
				self.hideLoading()
				AppProvider.apiKey = self.textField.text
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
	
	
}
