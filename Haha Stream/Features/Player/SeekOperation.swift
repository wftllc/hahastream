import Foundation
import CoreMedia

class SeekOperation {
	static public let SeekUXTimeoutSeconds: TimeInterval = -1.5
	
	var completionDate: Date?
	var initialMediaTime: CMTime
	//	var targetMediaTime: CMTime
	var swipes: Int = 0
	var isCanceled = false
	
	var offsetSeconds: Int { get {
		return totalValue(forSwipes: swipes)
		}}
	
	var targetSeekTime: CMTime {
		return CMTimeAdd(initialMediaTime, CMTimeMakeWithSeconds(Double(offsetSeconds), initialMediaTime.timescale))
	}
	
	func proposedSeekTime(withAdditionalSwipes swipes: Int) -> CMTime {
		let swipes = self.swipes+swipes
		let offset = totalValue(forSwipes: swipes)
		return CMTimeAdd(initialMediaTime, CMTimeMakeWithSeconds(Double(offset), initialMediaTime.timescale))
	}
	
	func cancel() {
		//just mark is canceled
		isCanceled = true
	}
	/*
	tells is this op is still active. a seek is active if < SeekUxTimeSeconds
	have elapsed since the seek completed
	*/
	var active: Bool {
		return !isCanceled && (self.completionDate == nil || self.completionDate!.timeIntervalSinceNow > SeekOperation.SeekUXTimeoutSeconds)
	}
	
	init(initialMediaTime: CMTime) {
		self.initialMediaTime = initialMediaTime
	}
	
	func totalValue(forSwipes swipes: Int) -> Int {
		let absSwipes = abs(swipes)
		var value: Int = 0

		var swipe = 1;
		
		repeat {
			switch(swipe) {
			case 0:
				value += 0
			case 1...2:
				value += 5
			case 3...3: //just 10 - 30 seconds :)
				value += 20
			case 4...8: // 3 .. 6 swipes min in 0:30s (30s => 3 min)
				value += 30
			case 9...10: // 3 min => 5 min; 1 min interval
				value += 60
			case 11...15: //5 min => 30 min; 5 min interval
				value += 300
			default: //30+ 15 min incr
				value += 900
			}
			swipe += 1
		} while swipe <= absSwipes
		
		return swipes < 0 ? -value : value
	}
	func intervalValueM(forSwipes swipes: Int) -> Double {
		return Double(totalValue(forSwipes: swipes)) / 60.0
	}
	
	func swipe(_ offset: Int) {
		swipes += offset
		self.completionDate = nil
	}
}
