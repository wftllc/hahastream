import UIKit

class PlayerOverlayView: UIView {
	@IBOutlet weak var label: UILabel!
	@IBOutlet weak var visualEffectView: UIVisualEffectView!

	override func awakeFromNib() {
		super.awakeFromNib();
		self.visualEffectView.layer.cornerRadius = 7;
		self.visualEffectView.layer.masksToBounds = true
		
	}
	
}


extension UIView {
	
	@discardableResult   // 1
	func fromNibNamed<T : UIView>(_ name: String) -> T? {   // 2
		guard let view = Bundle.main.loadNibNamed(name, owner: self, options: nil)?[0] as? T else {    // 3
			// xib not loaded, or it's top view is of the wrong type
			return nil
		}
		//		self.addSubview(view)     // 4
		//		view.translatesAutoresizingMaskIntoConstraints = false   // 5
		//		view.attach
		//		view.layoutAttachAll(to: self)   // 6
		return view   // 7
	}
}
