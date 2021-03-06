import Foundation
import UIKit

extension UIViewController {
	var appRouter: AppRouter {
		return (UIApplication.shared.delegate as! AppDelegate).router;
	}

	//these are exposed as @objc functions to allow subclasses to override
	
	@objc func showLoading(animated: Bool) {
		let loadingController = UIAlertController(title: "Loading...", message: "Loading from network...", preferredStyle: .alert)
		present(loadingController, animated: animated, completion: nil);
	}
	
	@objc func hideLoading(animated: Bool, completion: (()->Void)? = nil) {
		guard let _ = self.presentedViewController as? UIAlertController else {
			if let c = completion {
				c()
			}
			return;
		}
		dismiss(animated: animated, completion:completion)
	}

	@objc func showAlert(title: String, message: String) {
		let acceptButtonTitle = NSLocalizedString("OK", comment: "")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .default) { _ in
			
		}
		alertController.addAction(acceptAction)
		present(alertController, animated: true, completion: nil);
	}

	@objc func showAlert(title: String, message: String, onDismiss:(()->Void)? = nil) {
		let acceptButtonTitle = NSLocalizedString("OK", comment: "")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .default) { _ in
			onDismiss?()
		}
		alertController.addAction(acceptAction)
		present(alertController, animated: true, completion: nil);
	}
	@objc func showAlert(title: String, message: String, okTitle: String = "OK", onAccept:(()->Void)? = nil) {
		let acceptButtonTitle = NSLocalizedString(okTitle, comment: "")
		let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .destructive) { _ in
			onAccept?()
		}
		alertController.addAction(acceptAction)
		let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) 
		alertController.addAction(cancelAction)
		present(alertController, animated: true, completion: nil);
	}

	
	@objc func showLoginAlert(message: String) {
		let title = "Authorization Problem"
		let acceptButtonTitle = "Login Again"
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .default) { _ in
			self.appRouter.gotoLoginScreen()
		}
		alertController.addAction(acceptAction)
		
		let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
		let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil);
	}
	
	
}
