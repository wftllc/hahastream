import Foundation

final class Sport: NSObject, FromDictable {
	public var name: String;
	public var path: String?;
	
	static func fromDictionary(_ dict:[String: Any]?) throws -> Self {
		guard let dict = dict else { throw FromDictableError.keyError(key: "<root>") }
		
		let name: String = try dict.value("name")
		let path = dict.value("collection_endpoint") as? String ?? dict.value("path") as? String
		//		let path: String = try? dict.value("collection_endpoint") ?? try? dict.value
		return self.init(name: name, path: path);
	}
	
	required public init(name: String, path: String?) {
		self.name = name;
		self.path = path;
	}
	
	override var description : String {
		return "\(name)";
	}
}

/*
[
{
"uuid":"bChvcf",
"name":"NBA TV",
"logo_url":"",
"kind":"channel",
"url":"/channels/bChvcf.json",
"title":"NBA TV"
},
{
"uuid":"utbUKe",
"sport":{
"id":1,
"path":"nba",
"name":"NBA"
},
"live":false,
"start_in_gmt":"2017-10-03T00:00:00.000Z",
"end_in_gmt":"2017-10-06T10:01:20.264Z",
"home_team":{
"id":779,
"name":"Wizards",
"league_id":null,
"location":"Washington",
"abbreviation":"WAS",
"logo":"/images/teams/nba/WAS.svg"
},
"away_team":{
"id":1015,
"name":null,
"league_id":null,
"location":null,
"abbreviation":"GUA",
"logo":"/images/teams/nba/GUA.svg"
},
"title":"  vs Washington Wizards",
"state":0,
"type":3,
"streams":[

],
"ended":true,
"live_data":{

},
"url":"/nba/games/utbUKe.json",
"ready_at":"2017-10-02T22:45:00.000Z",
"gt":10,
"kind":"game"
},
{
"uuid":"HKg98s",
"sport":{
"id":1,
"path":"nba",
"name":"NBA"
},
"live":false,
"start_in_gmt":"2017-10-03T00:30:00.000Z",
"end_in_gmt":"2017-10-06T10:01:20.265Z",
"home_team":{
"id":750,
"name":"Celtics",
"league_id":null,
"location":"Boston",
"abbreviation":"BOS",
"logo":"/images/teams/nba/BOS.svg"
},
"away_team":{
"id":751,
"name":"Hornets",
"league_id":null,
"location":"Charlotte",
"abbreviation":"CHA",
"logo":"/images/teams/nba/CHA.svg"
},
"title":"Charlotte Hornets vs Boston Celtics",
"state":0,
"type":3,
"streams":[

],
"ended":true,
"live_data":{

},
"url":"/nba/games/HKg98s.json",
"ready_at":"2017-10-02T23:15:00.000Z",
"gt":10,
"kind":"game"
},
{
"uuid":"zX3MPt",
"sport":{
"id":1,
"path":"nba",
"name":"NBA"
},
"live":false,
"start_in_gmt":"2017-10-03T01:00:00.000Z",
"end_in_gmt":"2017-10-06T10:01:20.265Z",
"home_team":{
"id":762,
"name":"Grizzlies",
"league_id":null,
"location":"Memphis",
"abbreviation":"MEM",
"logo":"/images/teams/nba/MEM.svg"
},
"away_team":{
"id":771,
"name":"Magic",
"league_id":null,
"location":"Orlando",
"abbreviation":"ORL",
"logo":"/images/teams/nba/ORL.svg"
},
"title":"Orlando Magic vs Memphis Grizzlies",
"state":0,
"type":3,
"streams":[

],
"ended":true,
"live_data":{

},
"url":"/nba/games/zX3MPt.json",
"ready_at":"2017-10-02T23:45:00.000Z",
"gt":10,
"kind":"game"
},
{
"uuid":"txgGWq",
"sport":{
"id":1,
"path":"nba",
"name":"NBA"
},
"live":false,
"start_in_gmt":"2017-10-03T01:30:00.000Z",
"end_in_gmt":"2017-10-06T10:01:20.266Z",
"home_team":{
"id":754,
"name":"Mavericks",
"league_id":null,
"location":"Dallas",
"abbreviation":"DAL",
"logo":"/images/teams/nba/DAL.svg"
},
"away_team":{
"id":764,
"name":"Bucks",
"league_id":null,
"location":"Milwaukee",
"abbreviation":"MIL",
"logo":"/images/teams/nba/MIL.svg"
},
"title":"Milwaukee Bucks vs Dallas Mavericks",
"state":0,
"type":3,
"streams":[

],
"ended":true,
"live_data":{

},
"url":"/nba/games/txgGWq.json",
"ready_at":"2017-10-03T00:15:00.000Z",
"gt":10,
"kind":"game"
},
{
"uuid":"cLuDsC",
"sport":{
"id":1,
"path":"nba",
"name":"NBA"
},
"live":false,
"start_in_gmt":"2017-10-03T02:00:00.000Z",
"end_in_gmt":"2017-10-06T10:01:20.266Z",
"home_team":{
"id":778,
"name":"Jazz",
"league_id":null,
"location":"Utah",
"abbreviation":"UTA",
"logo":"/images/teams/nba/UTA.svg"
},
"away_team":{
"id":1016,
"name":null,
"league_id":null,
"location":null,
"abbreviation":"SYD",
"logo":"/images/teams/nba/SYD.svg"
},
"title":"  vs Utah Jazz",
"state":0,
"type":3,
"streams":[

],
"ended":true,
"live_data":{

},
"url":"/nba/games/cLuDsC.json",
"ready_at":"2017-10-03T00:45:00.000Z",
"gt":10,
"kind":"game"
},
{
"uuid":"aRAsWZ",
"sport":{
"id":1,
"path":"nba",
"name":"NBA"
},
"live":false,
"start_in_gmt":"2017-10-03T03:00:00.000Z",
"end_in_gmt":"2017-10-06T10:01:20.267Z",
"home_team":{
"id":775,
"name":"Kings",
"league_id":null,
"location":"Sacramento",
"abbreviation":"SAC",
"logo":"/images/teams/nba/SAC.svg"
},
"away_team":{
"id":776,
"name":"Spurs",
"league_id":null,
"location":"San Antonio",
"abbreviation":"SAS",
"logo":"/images/teams/nba/SAS.svg"
},
"title":"San Antonio Spurs vs Sacramento Kings",
"state":0,
"type":3,
"streams":[

],
"ended":true,
"live_data":{

},
"url":"/nba/games/aRAsWZ.json",
"ready_at":"2017-10-03T01:45:00.000Z",
"gt":10,
"kind":"game"
},
{
"uuid":"47LAyU",
"sport":{
"id":1,
"path":"nba",
"name":"NBA"
},
"live":false,
"start_in_gmt":"2017-10-03T03:30:00.000Z",
"end_in_gmt":"2017-10-06T10:01:20.267Z",
"home_team":{
"id":761,
"name":"Lakers",
"league_id":null,
"location":"Los Angeles",
"abbreviation":"LAL",
"logo":"/images/teams/nba/LAL.svg"
},
"away_team":{
"id":755,
"name":"Nuggets",
"league_id":null,
"location":"Denver",
"abbreviation":"DEN",
"logo":"/images/teams/nba/DEN.svg"
},
"title":"Denver Nuggets vs Los Angeles Lakers",
"state":0,
"type":3,
"streams":[

],
"ended":true,
"live_data":{

},
"url":"/nba/games/47LAyU.json",
"ready_at":"2017-10-03T02:15:00.000Z",
"gt":10,
"kind":"game"
}
]
*/
