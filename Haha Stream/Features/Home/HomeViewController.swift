import UIKit

class HomeViewController: UITabBarController {
	public var provider: HahaProvider!
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var viewControllers:[UIViewController] = []
		
		self.provider.getSports(success: { (sports) in
			for sport in sports {
				viewControllers.append(self.appRouter.viewController(forSport: sport))
			}
			viewControllers.append(self.appRouter.loginViewController())
			self.setViewControllers(viewControllers, animated: false)
			self.setNeedsFocusUpdate();
//			self.updateFocusIfNeeded();
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure)
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	override var preferredFocusEnvironments: [UIFocusEnvironment] {
		let def = super.preferredFocusEnvironments;
		guard let vcs = self.viewControllers else {
			return def;
		}
		
		if vcs.count == 2 {
			//if only one sport, focus on it by default
			var res = def;
			res.insert(vcs[0], at: 0)
			return res
		}
		else {
			return def;
		}
	}
	
}
