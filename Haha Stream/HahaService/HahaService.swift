import Foundation
import Moya

enum HahaService {
	case getDeviceKey(deviceUUID: String)
	case activateDevice(deviceKey: String)
	case deactivateDevice()
	case getDeviceActivationStatus()
	case getGamesNoDate(sport: String);
	case getNFLGames(year: Int, seasonType: Int, week: Int)
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
		return [ //TODO: load these from os sources as appropriate
			"X-App" : "TvOS App",
			"X-App-Version": "1.1b1",
			"X-Device-Name": device.name,
			"X-Device-System": device.systemName,
			"X-Device-CPU": "ARM/x86/x64",
			"X-Id": device.identifierForVendor!.uuidString,
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
		case .getNFLGames(_, _ , _):
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
		case .getNFLGames(let year, let seasonType, let week):
			return [
				"season": year,
				"type": seasonType,
				"week": week
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
