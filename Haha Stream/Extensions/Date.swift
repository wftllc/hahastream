import Foundation

extension Date {
	var elapsedTimeString: String {
		let negative:Bool = self.timeIntervalSinceNow > 0;
		
		let timeSeconds = abs(Int64(self.timeIntervalSinceNow))
		let secondsElapsed = timeSeconds % 60;
		let minutesElapsed = (timeSeconds % 3600) / 60;
		let hoursElapsed = (timeSeconds % (60*60*60))/(60*60);

		var elapsed: String;
		if hoursElapsed > 0 {
			elapsed = String(format: "%dh%02dm%02ds", hoursElapsed, minutesElapsed, secondsElapsed);
		}
		else {
			elapsed = String(format: "%dm%02ds", minutesElapsed, secondsElapsed);
		}
		
		if negative {
			elapsed = "in \(elapsed)"
		}
		return elapsed;
	}
	var isToday: Bool {
		return Calendar.current.isDateInToday(self);
	}
	var isTomorrow: Bool {
		return Calendar.current.isDateInTomorrow(self);
	}
	var isYesterday: Bool {
		return Calendar.current.isDateInYesterday(self);
	}
}
