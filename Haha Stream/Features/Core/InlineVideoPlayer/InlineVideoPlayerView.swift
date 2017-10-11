//
//  InlineVideoPlayerView.swift
//  Haha Stream
//
//  Created by Jake Lavenberg on 10/10/17.
//  Copyright © 2017 WFT Productions LLC. All rights reserved.
//

import UIKit
import AVKit

class InlineVideoPlayerView: UIView {
	var player: AVPlayer? {
		set {
			self.playerLayer.player = newValue
		}
		get {
			return self.playerLayer.player
		}
	}
	
	var playerLayer: AVPlayerLayer {
		return self.layer as! AVPlayerLayer
	}
	
	override class var layerClass: Swift.AnyClass {
		return AVPlayerLayer.self
	}
}
