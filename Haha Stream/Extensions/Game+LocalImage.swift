import Foundation
import UIKit
import Kingfisher

extension Game: LocalImage {
	public typealias Completion = ((_ homeImage: Image?, _ awayImage: Image?, _ error: NSError?) -> ())
	
	fileprivate func fetchImages(_ completion: Completion?) {
		
		DispatchQueue.global().async {
			let semaphore = DispatchSemaphore(value: 0);
			
			let res1 = ImageResource(downloadURL: self.awayTeamLogoURL!);
			let res2 = ImageResource(downloadURL: self.homeTeamLogoURL!);
			
			var image1: Image?
			var image2: Image?
			var outerError: NSError?
			
			KingfisherManager.shared.retrieveImage(with: res1, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
				
				if let error = error {
					outerError = error;
				}
				image1 = image
				semaphore.signal()
			}
			
			KingfisherManager.shared.retrieveImage(with: res2, options: nil, progressBlock: nil) { (image, error, cacheType, url) in
				if let error = error {
					outerError = error;
				}
				image2 = image
				semaphore.signal()
			}
			
			semaphore.wait()
			semaphore.wait()
			
			completion?(image1, image2, outerError)
		}
		
	}
	
	public func saveLocalImage(_ completion: @escaping ((_ url: URL?, _ error: Error?) -> ())) {
		fetchImages { (image1, image2, error) in
			if let error = error {
				completion(nil, error)
			}
			else {
				DispatchQueue.global().async {
					do {
						let data = self.combine(image1: image1!, image2: image2!);
						try data.write(to: self.singleImageLocalURL)
						completion(self.singleImageLocalURL, nil)
					}
					catch {
						completion(nil, error)
					}
				}
			}
		}
	}
	
	public var localImageExists: Bool {
		return FileManager.default.fileExists(atPath: singleImageLocalURL.path);
	}
	
	public var singleImageLocalURL: URL {
		let name = self.uuid
		let fileURL = self.getCacheDirectory().appendingPathComponent(name).appendingPathExtension("png")
		return fileURL;
	}
	
	fileprivate func combine(image1: UIImage, image2: UIImage) -> Data {
		let topPadding: CGFloat = 40.0;
		let middlePadding: CGFloat = 40.0;
		let bottomPadding: CGFloat = 40.0;
		
		let str:NSString = NSString(string: self.startTimeString)
		let style = NSMutableParagraphStyle();
		style.alignment = .center
		var attr: [NSAttributedStringKey: Any] = [
			.paragraphStyle: style,
			.foregroundColor: UIColor.darkGray,
			]
		if let font = UIFont(name: UIFont.preferredFont(forTextStyle: .title1).fontName, size: 90) {
			attr[.font] = font
		}
		
		let textSize = str.size(withAttributes: attr)
		
		
		let width = max(image1.size.width, image2.size.width)
		let height: CGFloat = topPadding + image1.size.height + middlePadding + image2.size.height + middlePadding + textSize.height + bottomPadding;
		
		let finalWidth = height * 2/3
		let contextSize = CGSize(width: finalWidth, height: height)
		let renderer = UIGraphicsImageRenderer(size: contextSize)
		let x = (finalWidth - width)/2;
		let textRect = CGRect(origin: CGPoint(x: finalWidth/2 - textSize.width/2, y: height-textSize.height-bottomPadding), size: textSize);
		
		let data = renderer.pngData { (context) in
			context.cgContext.setFillColor(UIColor.white.cgColor)
			context.cgContext.fill(CGRect(origin: CGPoint(x:0, y:0), size: contextSize))
			
			image1.draw(at: CGPoint(x: x, y: topPadding))
			image2.draw(at: CGPoint(x: x, y: topPadding+image1.size.height+middlePadding))
			context.cgContext.setShouldSmoothFonts(true)
			context.cgContext.setFillColor(UIColor.lightGray.cgColor)
			str.draw(in: textRect, withAttributes: attr)
		}
		
		return data;
	}
	
	fileprivate func getCacheDirectory() -> URL {
		let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
		let path = paths[0]
		return path;
		//		return path.appendingPathComponent("games", isDirectory: true)
	}
}
