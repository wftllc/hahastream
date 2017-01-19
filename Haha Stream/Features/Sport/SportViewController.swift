import UIKit

class SportViewController: UISplitViewController {
	public var provider: HahaProvider!;
	public var sport: Sport!
	;
	override func viewDidLoad() {
		super.viewDidLoad()
		
		self.tabBarItem.title = sport.name;
		// Do any additional setup after loading the view.
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	/*
	// MARK: - Navigation
	
	// In a storyboard-based application, you will often want to do a little preparation before navigation
	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
	// Get the new view controller using segue.destinationViewController.
	// Pass the selected object to the new view controller.
	}
	*/
	
}
