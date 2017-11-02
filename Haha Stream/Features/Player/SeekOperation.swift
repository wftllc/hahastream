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
		case 0..<3:
			value = absSwipes * 15
		case 3..<7: // 0 .. 6 swipes min in 0:30s (0s => 3 min)
			value = 30 + 30 * (absSwipes-2) 
		case 7..<14: // 3 min => 10 min; 1 min interval
			value = 180 + 60 * (absSwipes-6)
		case 14..<18: //10 min => 30 min; 5 min interval
			value = 600 + 300 * (absSwipes-13)
		default: //20+ 10 min incr
			value = 1800 + (absSwipes-17) * 600
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
