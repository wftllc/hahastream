import UIKit
import AVKit

class AppRouter: NSObject {
	let appProvider: AppProvider
	let hahaProvider: HahaProvider;
	weak var window: UIWindow?;
	
	init(window: UIWindow?) {
		
		self.window = window
		self.appProvider = AppProvider()
		self.hahaProvider = HahaProvider(apiKey: self.appProvider.apiKey);
	}

	public func handleLoginComplete(withActivation activation: DeviceActivation) {
		appProvider.apiKey = activation.apiKey
		self.hahaProvider.apiKey = appProvider.apiKey
		gotoFirstScreen();
	}
	public func handleLogoutComplete() {
		appProvider.apiKey = nil
		self.hahaProvider.apiKey = appProvider.apiKey
		gotoFirstScreen();
	}

	func gotoFirstScreen() {
		if( appProvider.isInUnitTestMode ) {
			return
		}
		if( !appProvider.isLoggedIn ) {
			gotoLoginScreen()
		}
		else {
			gotoHomeScreen()
		}
	}
	
	public func openURL(_ url: URL) -> Bool {
		print("open url \(url)");
		
		let pathComponents = url.pathComponents;
		if pathComponents.count < 3 {
			return false;
		}
		let type = pathComponents[1].lowercased();
		let sport = pathComponents[2].lowercased()
		let identifier = pathComponents[3].lowercased();
		
		print(type, identifier)
		
		if( type == "game" || type == "channel"  ) {
			gotoHomeScreen();
			guard let vc = self.window?.rootViewController as? HomeViewController else {
				return false;
			};
			let loadingVC = self.loadingViewController()
			DispatchQueue.main.asyncAfter(deadline: .now()+0.1) {
				
			vc.present(loadingVC, animated: false, completion: {
				if type == "game" {
					loadingVC.selectGame(identifier, sport: sport);
				}
				else if type == "channel" {
					if let channelNumber = Int(identifier) {
						loadingVC.selectChannel(channelNumber, sport: sport)
					}
				}
			});
			}
			return true;
		}

		return false;
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
//		let detailViewController = splitViewController.viewControllers.last as? AVPlayerViewController
		masterViewController.delegate = splitViewController;
		//		masterViewController.sport = sport;
//		detailViewController.sport = sport;
		masterViewController.provider = self.hahaProvider;
		splitViewController.provider = self.hahaProvider
		return vc;
	}
	
	func accountViewController() -> AccountViewController {
		let vc = UIStoryboard(name: "Account", bundle: nil).instantiateInitialViewController() as! AccountViewController;
		let interactor = AccountInteractor(provider: self.hahaProvider, router: self)
		interactor.view = vc
		vc.interactor = interactor
		return vc;
	}
	
	func loginViewController() -> LoginViewController {
		let vc = UIStoryboard(name: "Login", bundle: nil).instantiateViewController(withIdentifier: "login") as! LoginViewController;
		let interactor = LoginInteractor(provider: self.hahaProvider, router: self)
		interactor.view = vc
		vc.interactor = interactor
		return vc;
	}

	func nowPlayingViewController() -> ContentListViewController {
		let vc = UIStoryboard(name: "ContentList", bundle: nil).instantiateInitialViewController() as! ContentListViewController
		let interactor = ContentListInteractorImpl(provider: hahaProvider, router: self)
		vc.interactor = interactor
		interactor.view = vc
		return vc;
	}
	
	func loadingViewController() -> LoadingViewController {
		let vc = UIStoryboard(name: "Loading", bundle: nil).instantiateInitialViewController() as! LoadingViewController
		vc.provider = hahaProvider;
		return vc;
	}
	
	func viewController(forSport sport: Sport) -> SportViewController {
		let vc = UIStoryboard(name: "Sport", bundle: nil).instantiateInitialViewController() as! SportViewController;
		vc.sport = sport;
		vc.provider = self.hahaProvider;

		let splitViewController = vc;
		let leftNavController = splitViewController.viewControllers.first as! UINavigationController

		let nowPlayingViewController = splitViewController.viewControllers.last as! ContentListViewController

		let interactor = ContentListInteractorImpl(provider: hahaProvider, router: self, sport: sport)
		nowPlayingViewController.interactor = interactor
		interactor.view = nowPlayingViewController
		nowPlayingViewController.provider = self.hahaProvider;

		let dateListViewController = leftNavController.topViewController as! DateListViewController
		dateListViewController.delegate = nowPlayingViewController;
		dateListViewController.sport = sport;

		return vc;
	}
	
	func goToScreen(forSport sport: Sport) {
		self.window?.rootViewController = viewController(forSport: sport);
	}

	func topViewController(controller: UIViewController?) -> UIViewController? {
		let controller = controller ?? window?.rootViewController
		
		if let navigationController = controller as? UINavigationController {
			return topViewController(controller: navigationController.visibleViewController)
		}
		if let tabController = controller as? UITabBarController {
			if let selected = tabController.selectedViewController {
				return topViewController(controller: selected)
			}
		}
		if let presented = controller?.presentedViewController {
			return topViewController(controller: presented)
		}
		return controller
	}

}
