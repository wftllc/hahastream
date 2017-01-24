import UIKit

class HomeViewController: HahaTabBarController {
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		var viewControllers:[UIViewController] = []
		
		viewControllers.append(self.appRouter.nowPlayingViewController());
		
		self.provider.getSports(success: { (theSports) in
			let sports = theSports.sorted(by: { (a, b) -> Bool in
				return a.name < b.name
			})
			for sport in sports {
				let tabBarItem = UITabBarItem(title: sport.name, image: nil, selectedImage: nil)
				let vc = self.appRouter.viewController(forSport: sport)
				vc.tabBarItem = tabBarItem
				viewControllers.append(vc)				
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
	/*
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
*/
	
}
