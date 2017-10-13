import UIKit

class SportViewController: UISplitViewController {
	public var provider: HahaProvider!;
	public var sport: Sport!
	;
	override func viewDidLoad() {
		super.viewDidLoad()
		if let dateVC = self.viewControllers[0] as? DateListViewController{
			print("got dateVC")
		}
		else if let nowPlayingVC = self.viewControllers[1] as? NowPlayingViewController {
			print("got nowPlayingVC")
		}
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Navigation
	
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
		if let dateVC = segue.destination as? DateListViewController{
			print("got dateVC")
		}
		else if let nowPlayingVC = segue.destination as? NowPlayingViewController {
			print("got nowPlayingVC")
		}
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	
}
