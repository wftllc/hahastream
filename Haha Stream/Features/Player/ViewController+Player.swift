import Foundation
import UIKit
import AVKit

extension HahaViewController {
	
	func selectGame(_ gameUUID: String, sport: String) {
		showLoading(animated: true)
		provider.getGame(sportName: sport, gameUUID: gameUUID, success: { (game) in
			guard let game = game else {
				self.hideLoading(animated: true, completion: {
					self.showAlert(title: "Game not Found", message: "A matching game could not be found. Please try again.");
				})
				return;
			}
			//just put in the sport by hand, since it's not returned by api
			game.sport = Sport(name: sport, path: "")
			self.selectGame(game);
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure
		)
	}
	
	func selectChannel(_ identifier: Int, sport: String) {
		let __FIXME_REIMPLEMENT_THIS: Any? = nil

//		showLoading(animated: true)
//		//fake it!
//		let channel = Channel(identifier: identifier, title: "\(sport) channel", notes: nil, active: true);
//		channel.sport = Sport(name: sport, path: "");
//
//		provider.getStream(channel: channel, success: { (stream) in
//			self.hideLoading(animated: true, completion: {
//				if let stream = stream {
//					self.playURL(stream.url)
//				}
//				else {
//					self.showAlert(title: "No Stream", message: "Couldn't find stream for \(channel.title)");
//				}
//			});
//		}, apiError: apiErrorClosure,
//		   networkFailure: networkFailureClosure
//		)
	}
	
	func selectGame(_ game: Game) {
		showLoading(animated: true)
		provider.getStreams(game: game, success: { (streams) in
			if streams.count == 1 {
				self.hideLoading(animated: false, completion: {
					self.playStream(stream: streams[0], game: game)
				})
			}
			else {
				self.hideLoading(animated: true, completion: { 
					self.showStreamChoiceAlert(game: game, streams: streams)
				})
			}
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure
		)
	}

	@objc func playStream(stream: Stream, game: Game) {
		showLoading(animated: true)
		provider.getStreamURL(forStream: stream, inGame: game, success: { (streamURL) in
			self.hideLoading(animated: true, completion: {
				self.playURL(streamURL.url);
			});
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure
		)
	}
	

	@objc func onStreamChoiceCanceled() {
		
	}
	func showStreamChoiceAlert(game: Game, streams: [Stream]) {
		let title = "Choose Stream"
		let message: String;
		let awayTeam = game.awayTeam.name ?? game.awayTeam.abbreviation ?? "???"
		let homeTeam = game.homeTeam.name ?? game.homeTeam.abbreviation ?? "???"
		message = "\(awayTeam) at \(homeTeam)";
		
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		for stream in streams {
			let title = "\(stream.title) stream";
			let acceptAction = UIAlertAction(title: title, style: .default) { _ in
				self.playStream(stream: stream, game: game)
			}
			alertController.addAction(acceptAction)
		}
		
		let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
		let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel) { _ in
			self.onStreamChoiceCanceled()
		}
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	@objc func playURL(_ url: URL) {
		// Create an AVPlayer, passing it the HTTP Live Streaming URL.
		let player = AVPlayer(url: url)
		
		// Create a new AVPlayerViewController and pass it a reference to the player.
		let controller = PlayerViewController()
		controller.player = player
		
		// Modally present the player and call the player's play() method when complete.
		present(controller, animated: true) {
			player.play()
		}
		
	}

}
