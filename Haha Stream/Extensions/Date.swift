import Foundation

extension Date {
	var elapsedTimeString: String {
		let timeSeconds = -Int64(self.timeIntervalSinceNow)
		let secondsElapsed = timeSeconds % 60;
		let minutesElapsed = (timeSeconds % 3600) / 60;
		let hoursElapsed = (timeSeconds % (60*60*60))/(60*60);
		let elapsed = String(format: "%dh%02dm%02ds", hoursElapsed, minutesElapsed, secondsElapsed);
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
