import Foundation
import UIKit
import Moya

extension UIViewController {
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
	

	func handleApiError(_ error: Any) {
		print("handleApiError", error);
		self.hideLoading(animated: true, completion: {
			var title = "Server Error";
			var message = "Got unexpected server response. There might not be any streams available for this item. Please try again. Error: "
			if let hahaError = error as? HahaError {
				if hahaError.underlyingResponse?.statusCode == 401 {
					self.showLoginAlert(message: hahaError.error);
					return;
				}
				title = hahaError.error;
				message = "So the server says."
			}
			else if let desc = (error as? MoyaError)?.errorDescription {
				message.append(" \(desc)");
			}
			self.showAlert(title: title, message: message)
		})
	}
	
	func handleNetworkError(_ error: MoyaError) {
		print("handleNetworkError", error);
		self.hideLoading(animated: true, completion: {
			self.showAlert(title: "Network Error", message: "There was a network error. Please make sure you are online.");
		})
	}
}
