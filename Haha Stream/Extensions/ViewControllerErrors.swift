import Foundation
import UIKit
import Moya

extension UIViewController {
	
	func showAlert(title: String, message: String) {
		let acceptButtonTitle = NSLocalizedString("OK", comment: "")
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		let acceptAction = UIAlertAction(title: acceptButtonTitle, style: .default) { _ in
			
		}
		alertController.addAction(acceptAction)
		present(alertController, animated: true, completion: nil);
	}
	
	var apiErrorClosure: (Any) -> Void {
		return { (_ error: Any) -> Void in
			self.handleApiError(error);
		}
	}
	
	var networkFailureClosure: (MoyaError) -> Void {
		return { (_ error: MoyaError) -> Void in
			self.handleNetworkError(error);
		}
	}
	
	var appRouter: AppRouter {
		return (UIApplication.shared.delegate as! AppDelegate).router;
	}
	
	func showLoginAlert(message: String) {
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
	
	
	func handleApiError(_ error: Any) {
		print("handleApiError", error);
		var title = "Server Error";
		var message = "Got unexpected server response. There might not be any streams available for this item. Please try again. Error: "
		if let hahaError = error as? HahaError {
			if hahaError.underlyingResponse?.statusCode == 401 {
				showLoginAlert(message: hahaError.error);
				return;
			}
			title = hahaError.error;
			message = "So the server says."
		}
		else if let desc = (error as? MoyaError)?.errorDescription {
				message.append(" \(desc)");
		}
		showAlert(title: title, message: message)
	}
	
	func handleNetworkError(_ error: MoyaError) {
		print("handleNetworkError", error);
		self.showAlert(title: "Network Error", message: "There was a network error. Please make sure you are online.");
		/*
		print(error);
		*/
	}
}
