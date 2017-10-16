import Foundation
import Moya

enum HahaService {
	case getDeviceKey(deviceUUID: String)
	case activateDevice(deviceKey: String)
	case deactivateDevice()
	case getDeviceActivationStatus()
	case getGamesNoDate(sport: String);
	case getNFLGames(week: NFLWeek?)
	case getGames(sport: String, year: Int, month: Int, day: Int);
	case getGame(sport: String, uuid: String)
	//	case getGamesByDate(sport: String, year: Int, month: Int, day: Int);
	case getSports;
	case getChannels(sport: String);
	case getChannelStreams(channelId: String);
	case getStreams(sport: String, gameId: String);
	case getStreamURLForItem(itemId: String, streamId: String, sport: String?);
//	case getStreamForChannel(channelId: String);
	case scrapeVCSChannels;
}

extension HahaService: TargetType {
	var headers: [String : String]? {
		let device = UIDevice.current
		/*
To get App version: NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
To get Build version: NSString *buildVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
		*/
		
		let appVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "Unknown"
		let buildVersion = Bundle.main.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "Unknown"
		return [ //TODO: load these from os sources as appropriate
			"X-App" : "TvOS App",
			"X-App-Version": "\(appVersion)b\(buildVersion)",
			"X-Device-Name": device.model,
			"X-Device-System": device.systemName,
			"X-Device-CPU": "ARM/x86/x64",
			"X-Id": "\(device.identifierForVendor!.uuidString)-b",
			"X-Device-Version": device.systemVersion,
		]
	}
	
	var baseURL: URL { return URL(string: "https://hehestreams.com/api/v1")! }
	
	var path: String {
		switch self {
		case .getDeviceKey(_):
			return "devices/register"
		case .activateDevice(_):
			return "devices/activate"
		case .deactivateDevice():
			return "devices/deactivate"
		case .getDeviceActivationStatus():
			return "devices/check"
		case .getSports:
			return "users/services";
		case .getGame(let sport, let uuid):
			return "/\(sport.urlEscaped)/games/\(uuid.urlEscaped)";
		case .getGames(let sport, _, _, _):
			return "/\(sport.urlEscaped)/games";
		case .getGamesNoDate(let sport):
			return "/\(sport.urlEscaped)/games"
		case .getNFLGames(_):
			return "/nfl/games"
		case .getChannelStreams(let uuid):
			return "/channels/\(uuid.urlEscaped)/streams";
		case .getStreams(let sport, let uuid):
			return "/\(sport.urlEscaped)/games/\(uuid.urlEscaped)/streams";
		case .getStreamURLForItem(let itemId, let streamId, let sport):
			if let sport = sport {
				return "/\(sport.urlEscaped)/games/\(itemId.urlEscaped)/streams/\(streamId.urlEscaped)";
			}
			else { //channel
				return "/channels/\(itemId.urlEscaped)/streams/\(streamId.urlEscaped)";
			}
		case .getChannels(let sport):
			return "/\(sport.urlEscaped)/channels";
		case .scrapeVCSChannels:
			return "vcs"
		}
	}
	
	var method: Moya.Method {
		switch self {
			
		default:
			return .get;
		}
	}
	
	var parameters: [String: Any] {
		switch self {
		case .getDeviceKey(let deviceUUID):
			return [
				"uiud": deviceUUID
			]
		case .activateDevice(let deviceKey):
			return [
				"code": deviceKey
			]
		case .getGames(_, let year, let month, let day):
			return [
				"date": String(format: "%2d-%02d-%1d", month, day, year)
			]
		case .getNFLGames(let nflWeek):
			guard let nflWeek = nflWeek else { return [:] }
			//pre-week# or reg-week#
			//season=2016&week=pre-2
			let prefix = nflWeek.type == .preSeason ? "pre" : "reg"
			return [
				"season": nflWeek.year,
				"week": "\(prefix)-\(nflWeek.week)"
			]
		default:
			return [:];
		}
	}
	
	var parameterEncoding: ParameterEncoding {
		return URLEncoding.default;
	}
	
	var task: Task {
		return .requestParameters(parameters: self.parameters, encoding: self.parameterEncoding)
	}
	
	var sampleData: Data {
		switch self {
		default:
			return "".utf8Encoded;
		}
	}
	
}

// MARK: - Helpers
private extension String {
	var urlEscaped: String {
		return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
	}
	
	var utf8Encoded: Data {
		return self.data(using: .utf8)!
	}
}
