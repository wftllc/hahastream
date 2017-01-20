import Foundation
import Moya

enum HahaService {
	case getGamesNoDate(sport: String);
	case getGames(sport: String, year: Int, month: Int, day: Int);
//	case getGamesByDate(sport: String, year: Int, month: Int, day: Int);
	case getSports;
	case getChannels(sport: String);
	case getStreams(sport: String, gameUUID: String);
	case getStreamForChannel(sport: String, channelId: Int);
}

extension HahaService: TargetType {
	var baseURL: URL { return URL(string: "https://hehestreams.xyz/api/v1")! }
	
	var path: String {
		switch self {
		case .getSports:
			return "users/login";
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
		}
	}

	var method: Moya.Method {
		switch self {
			
		default:
			return .get;
		}
	}
	
	var parameters: [String: Any]? {
		switch self {
		case .getGames(_, let year, let month, let day):
				return [
					"date": String(format: "%4d-%1d-%1d", year, month, day)
			]
			
		default:
			return nil;
		}
	}
	
	var parameterEncoding: ParameterEncoding {
		return URLEncoding.default;
	}
	
	var task: Task {
		return .request;
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
