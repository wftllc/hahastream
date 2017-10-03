import Foundation
import Moya

enum HahaService {
	case getDeviceKey(deviceUUID: String)
	case activateDevice(deviceKey: String)
	case getGamesNoDate(sport: String);
	case getGames(sport: String, year: Int, month: Int, day: Int);
	case getGame(sport: String, uuid: String)
	//	case getGamesByDate(sport: String, year: Int, month: Int, day: Int);
	case getSports;
	case getChannels(sport: String);
	case getStreams(sport: String, gameUUID: String);
	case getStreamForChannel(sport: String, channelId: Int);
	case scrapeVCSChannels;
}

extension HahaService: TargetType {
	var headers: [String : String]? {
		let device = UIDevice.current
		return [ //TODO: load these from os sources as appropriate
			"X-App" : "TvOS App",
			"X-App-Version": "1.1b1",
			"X-Device-Name": device.name,
			"X-Device-System": device.systemName,
			"X-Device-CPU": "ARM/x86/x64",
			"X-Id": device.identifierForVendor!.uuidString+String(format: "%d", arc4random()),
			"X-Device-Version": device.systemVersion,
		]
	}
	
	var baseURL: URL { return URL(string: "https://hehestreams.com/api/v1")! }
	
	var path: String {
		switch self {
		case .getDeviceKey(_):
			return "devices/ping"
		case .activateDevice(_):
			return "devices/activate"
		case .getSports:
			return "users/services";
		case .getGame(let sport, let uuid):
			return "/\(sport.urlEscaped)/games/\(uuid.urlEscaped)";
		case .getGames(let sport, _, _, _):
			return "/\(sport.urlEscaped)/games";
		case .getGamesNoDate(let sport):
			return "/\(sport.urlEscaped)/games";
		case .getStreams(let sport, let uuid):
			return "/\(sport.urlEscaped)/games/\(uuid.urlEscaped)/streams";
		case .getChannels(let sport):
			return "/\(sport.urlEscaped)/channels";
		case .getStreamForChannel(let sport, let channelId):
			return "/\(sport.urlEscaped)/channels/\(channelId)";
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
				"date": String(format: "%4d-%1d-%1d", year, month, day)
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
