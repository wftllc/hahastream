import Foundation

final class Stream: NSObject, FromDictable {
/*
"source": "Home",
"url": "http://hehestreams.xyz/nba/games/675d22ae7d4629c2/streams.m3u8?gt=1&htoken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0IjoxNDg0NzAzOTg5LCJzbyI6eyJjbGFzcyI6Ik5iYUdhbWUiLCJpZCI6NDMyODQsImYiOmZhbHNlLCJmZm0iOmZhbHNlfSwidSI6eyJpZCI6MTgxMzAsImF4IjpbIk5CQSJdLCJpcCI6IjY3LjI0NS4yMjcuMTQzIiwiY2UiOnRydWUsInVhIjoiOTYwMjI4NGMifX0.3XiWbmHrEukrcSJn83E07YTvpUvYWC5aunBz2b74xMo&quality=master",
"expires_at": "2017-01-18T02:46:30.005+00:00"
*/
	public var source: String;
	public var url: URL;
	public var expiresAt: Date;
	
	static func fromDictionary(_ dict:[String: Any]) -> Stream? {
		guard let source = dict["source"] as? String else { return nil }
		guard let url = URL(string: (dict["url"] as? String ?? "")) else { return nil }
		let date: Date;
		//for some reason this date is coming in as seconds since 1970, losing the string
		if let dateString = dict["expires_at"] as? String {
			guard let theDate = self.dateFormatter.date(from: dateString) else { return nil }
			date = theDate;
		}
		else if let dateInterval = dict["expires_at"] as? TimeInterval {
			date = Date(timeIntervalSince1970: dateInterval);
		}
		else {
			return nil
		}
		return Stream(source: source, url: url, expiresAt: date);
	}
	
	static var dateFormatter: DateFormatter = {
		let df = DateFormatter();
		df.locale = Locale(identifier: "en_US_POSIX");
		df.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSZ'"
		return df;
	}()

	
	required public init(source: String, url: URL, expiresAt: Date) {
		self.source = source;
		self.url = url;
		self.expiresAt = expiresAt;
	}
	
	override var description : String {
		return "\(source), expires in \(expiresAt.timeIntervalSinceNow) seconds";
	}
}
