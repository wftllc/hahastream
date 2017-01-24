import Foundation
import UIKit
import AVKit

extension HahaViewController {
	func selectGame(_ game: Game) {
		showLoading(animated: true)
		provider.getStreams(sport: game.sport, game: game, success: { (streams) in
			if streams.count == 1 {
				self.hideLoading(animated: true, completion: {
					self.playURL(streams.first!.url)
				});
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

	func playStream(source: String, game: Game) {
		showLoading(animated: true)
		provider.getStreams(sport: game.sport, game: game, success: { (streams) in
			self.hideLoading(animated: true, completion: {
				guard let stream = streams.filter({$0.source == source}).first else {
					self.showAlert(title: "Stream not Found", message: "A matching stream could not be found. Please try again.");
					return;
				}
				self.playURL(stream.url);
			});
		}, apiError: apiErrorClosure,
		   networkFailure: networkFailureClosure
		)
	}
	

	/// Shows an alert with "OK" and "Cancel" buttons.
	func showStreamChoiceAlert(game: Game, streams: [Stream]) {
		let title = "Choose Stream"
		let message: String;
		if let awayTeam = game.awayTeam, let homeTeam = game.homeTeam {
			message = "\(awayTeam) at \(homeTeam)";
		}
		else {
			message = game.title;
		}
		
		let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
		for stream in streams {
			// Create the actions.
			//			print("available stream \(stream)")
			let title = "\(stream.source) stream";
			let acceptAction = UIAlertAction(title: title, style: .default) { _ in
				//if stream expires in less than one second, refresh and play it
				//				print("play stream \(stream)")
				if( stream.expiresAt.timeIntervalSinceNow <= 1 ) {
					self.playStream(source: stream.source, game: game);
				}
				else {
					self.playURL(stream.url);
				}
			}
			alertController.addAction(acceptAction)
		}
		
		let cancelButtonTitle = NSLocalizedString("Cancel", comment: "")
		let cancelAction = UIAlertAction(title: cancelButtonTitle, style: .cancel)
		alertController.addAction(cancelAction)
		
		present(alertController, animated: true, completion: nil)
	}
	
	func playURL(_ url: URL) {
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
