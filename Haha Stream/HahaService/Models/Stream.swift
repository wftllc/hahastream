import Foundation

final class Stream: NSObject, FromDictable {
/*
"source": "Home",
"url": "http://hehestreams.xyz/nba/games/675d22ae7d4629c2/streams.m3u8?gt=1&htoken=eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJ0IjoxNDg0NzAzOTg5LCJzbyI6eyJjbGFzcyI6Ik5iYUdhbWUiLCJpZCI6NDMyODQsImYiOmZhbHNlLCJmZm0iOmZhbHNlfSwidSI6eyJpZCI6MTgxMzAsImF4IjpbIk5CQSJdLCJpcCI6IjY3LjI0NS4yMjcuMTQzIiwiY2UiOnRydWUsInVhIjoiOTYwMjI4NGMifX0.3XiWbmHrEukrcSJn83E07YTvpUvYWC5aunBz2b74xMo&quality=master",
"expires_at": "2017-01-18T02:46:30.005+00:00"
*/
	
	/*
channel stream:
{
"id": 2,
"source": "Live",
"title": "NBA TV",
"active": true,
"qualities": {
"400": "224p",
"800": "360p",
"1600": "540p",
"3000": "720p"
},
"url": "http://nlds16.cdnak.neulion.com/nlds/nba/nba247/as/live/ipad.m3u8?hdnea=expires%3D1484948421~access%3D%2Fnlds%2Fnba%2Fnba247%2Fas%2Flive%2F*~md5%3D8cd23aff2455dbcc91c5b8d6ce3530e2%26nltid%3Dnba%26nltdt%3D6%26nltnt%3D1",
"notes": null
}
*/
	public var source: String;
	public var url: URL;
	public var expiresAt: Date;
	
	static func fromDictionary(_ dict:[String: Any]) -> Stream? {
		guard let source = dict["source"] as? String else { return nil }
		guard let url = URL(string: (dict["url"] as? String ?? "")) else { return nil }
		let active = dict["active"] as? Bool ?? false //only in channel streams
		let date: Date;
		//for some reason this date is (sometimes??) getting parsed as seconds since 1970, losing the string
		if let dateString = dict["expires_at"] as? String {
			guard let theDate = self.dateFormatter.date(from: dateString) else { return nil }
			date = theDate;
		}
		else if let dateInterval = dict["expires_at"] as? TimeInterval {
			date = Date(timeIntervalSince1970: dateInterval);
		}
		else {
			if active {
				//pretend it just started.
				date = Date(timeIntervalSinceNow: -1)
			}
			else {
				return nil;
			}
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
