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
		let value: Int

		switch(absSwipes) {
		case 0:
			value = 0
		case 1:
			value = 10
		case 2..<3: //just 10 - 30 seconds :)
			value = 10+absSwipes * 20
		case 3..<7: // 3 .. 6 swipes min in 0:30s (30s => 3 min)
			value = 30 + 30 * (absSwipes-2) 
		case 7..<15: // 3 min => 10 min; 1 min interval
			value = 120 + 60 * (absSwipes-6)
		case 15..<19: //10 min => 30 min; 5 min interval
			value = 600 + 300 * (absSwipes-14)
		default: //30+ 15 min incr
			value = 1800 + (absSwipes-18) * 900
		}
		
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
