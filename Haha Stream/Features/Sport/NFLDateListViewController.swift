import UIKit

protocol NFLDateListDelegate: AnyObject {
	func nflDateDidSelect(_ week: NFLWeek)
}

class NFLDateListViewController: DateListViewController {
	weak var nflDelegate: NFLDateListDelegate?;
	var data: [NFLWeek] = []
	
	
//	override func viewDidLoad() {
//		super.viewDidLoad()
//		self.title = "NFL"
//		setupDates();
//		tableView.reloadData();
//		tableView.remembersLastFocusedIndexPath = true;
//		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
//			self.tableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none);
//		}
//	}
	
//	override func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
//		return IndexPath(item: 1, section: 0);
//	}
	
	override func setupDates() {
		let years = [2017, 2016, 2015, 2014, 2013, 2012, 2011]
		let weekTypes:[NFLWeekType] = [.playoffs, .regularSeason, .preSeason]
		for year in years {
			for weekType in weekTypes {
				for week in weekType.weeks {
					data.append(NFLWeek(year: year, type: weekType, week: week))
				}
			}
		}
		
	}
	
	override func didReceiveMemoryWarning() {
		super.didReceiveMemoryWarning()
		// Dispose of any resources that can be recreated.
	}
	
	// MARK: - Table view data source
	
	override func numberOfSections(in tableView: UITableView) -> Int {
		return 1
	}
	
	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return self.data.count;
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "dateRightDetailCell", for: indexPath);
		let week = self.data[indexPath.row];
		
		cell.textLabel?.text = week.title;
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let week = self.data[indexPath.row];
		self.nflDelegate?.nflDateDidSelect(week)
	}
}
