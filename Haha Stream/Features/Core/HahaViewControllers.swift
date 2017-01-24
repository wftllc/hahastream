import UIKit

class HahaViewController: UIViewController {
	var loadingController: UIAlertController?
	var provider: HahaProvider!
}
class HahaTableViewController: UITableViewController {
	var loadingController: UIAlertController?
	var provider: HahaProvider!
}

class HahaTabBarController: UITabBarController {
	var loadingController: UIAlertController?
	var provider: HahaProvider!
}

class HahaSplitViewController: UISplitViewController {
	var loadingController: UIAlertController?
	var provider: HahaProvider!
}
