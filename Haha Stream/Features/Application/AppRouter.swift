import UIKit
import AVKit

class AppRouter: NSObject {
	var hahaProvider: HahaProvider!;
	weak var window: UIWindow?;
	
	init(window: UIWindow?) {
		self.window = window
		self.hahaProvider = HahaProvider(apiKey: AppProvider.apiKey);
	}

	public func handleLoginComplete() {
		self.hahaProvider = HahaProvider(apiKey: AppProvider.apiKey);
		gotoFirstScreen();
	}
	
	func gotoFirstScreen() {
		if( AppProvider.apiKey == nil ) {
			gotoLoginScreen()
		}
		else {
			gotoHomeScreen()
		}
	}
	
	public func gotoLoginScreen() {
		let vc = loginViewController();
		self.window?.rootViewController = vc;
	}
	
//	public func gotoNbaScreen() {
//		let sport = Sport(name: "NBA", path: "/nba", status: true);
//		goToSportScreen(sport: sport)
//	}
	
	func gotoHomeScreen() {
		let vc = UIStoryboard(name: "Home", bundle: nil).instantiateViewController(withIdentifier: "home") as! HomeViewController;
		vc.provider = hahaProvider;
		self.window?.rootViewController = vc;
	}
	
	func vcsViewController() -> VCSViewController {
		let vc = UIStoryboard(name: "VCS", bundle: nil).instantiateInitialViewController() as! VCSViewController;
		
		vc.provider = self.hahaProvider;
		
		let splitViewController = vc;
		let leftNavController = splitViewController.viewControllers.first as! UINavigationController
		let masterViewController = leftNavController.topViewController as! VCSChannelListViewController
		let detailViewController = splitViewController.viewControllers.last as? AVPlayerViewController
		masterViewController.delegate = splitViewController;
		//		masterViewController.sport = sport;
//		detailViewController.sport = sport;
		masterViewController.provider = self.hahaProvider;
		splitViewController.provider = self.hahaProvider
		return vc;
	}

	
	func loginViewController() -> LoginViewController {
		let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController;
		vc.provider = hahaProvider;
		return vc;
	}
	
	func nowPlayingViewController() -> NowPlayingViewController {
		let vc = UIStoryboard(name: "NowPlaying", bundle: nil).instantiateInitialViewController() as! NowPlayingViewController
		vc.provider = hahaProvider;
		return vc;
	}
	
	func viewController(forSport sport: Sport) -> SportViewController {
		let vc = UIStoryboard(name: "Sport", bundle: nil).instantiateInitialViewController() as! SportViewController;
		vc.sport = sport;
		vc.provider = self.hahaProvider;

		let splitViewController = vc;
		let leftNavController = splitViewController.viewControllers.first as! UINavigationController
		let masterViewController = leftNavController.topViewController as! DateListViewController
		let detailViewController = splitViewController.viewControllers.last as! GamesViewController
		masterViewController.delegate = detailViewController;
//		masterViewController.sport = sport;
		detailViewController.sport = sport;
		detailViewController.provider = self.hahaProvider;
		return vc;
	}

	
	
	func goToScreen(forSport sport: Sport) {
		self.window?.rootViewController = viewController(forSport: sport);
	}

}
