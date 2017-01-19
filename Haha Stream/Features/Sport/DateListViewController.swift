import UIKit

protocol DateListDelegate: class {
	func dateListDidSelect(date: Date);
}

class DateListViewController: UITableViewController {
	weak var delegate: DateListDelegate?;
	var dates:[Date]!;
	let daysToShow = 1000;
	
	var dateFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.current;
		df.dateStyle = .medium;
		return df;
	}()
	
	var dateFormatterDayOfWeek: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale.current;
		df.dateFormat = "EEE";
		return df;
	}()
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		setupDates();
		tableView.reloadData();
		tableView.remembersLastFocusedIndexPath = true;
		DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
		self.tableView.selectRow(at: IndexPath(row: 1, section: 0), animated: false, scrollPosition: .none);
		}
	}
	
	override func indexPathForPreferredFocusedView(in tableView: UITableView) -> IndexPath? {
		return IndexPath(item: 1, section: 0);
	}

	func setupDates() {
		dates = [];
		let calendar = Calendar.current;
		let today = Date();
		
		let tomorrow = calendar.date(byAdding: .day, value: 1, to: today);
		
		dates.append(tomorrow!);
		dates.append(today);
		
		for i in 1 ... daysToShow {
			dates.append(calendar.date(byAdding: .day, value: -i, to: today)!);
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
		return self.dates.count;
	}
	
	
	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: "dateRightDetailCell", for: indexPath);
		let date = self.dates[indexPath.row];
		let calendar = Calendar.current;

		let title: String;
		if( calendar.isDateInToday(date)) {
			let weekday = dateFormatterDayOfWeek.string(from: date);
			title = "Today (\(weekday))"
		}
		else if( calendar.isDateInYesterday(date)) {
			let weekday = dateFormatterDayOfWeek.string(from: date);
			title = "Yesterday (\(weekday))"
		}
		else if( calendar.isDateInTomorrow(date)) {
			let weekday = dateFormatterDayOfWeek.string(from: date);
			title = "Tomorrow (\(weekday))";
		}
		else {
			title = self.dateFormatter.string(from: date);
		}
		
		cell.textLabel?.text = title;
		
		return cell
	}
	
	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		let date = self.dates[indexPath.row];
		self.delegate?.dateListDidSelect(date: date);
	}
}
