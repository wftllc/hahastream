import Foundation
import UIKit


extension Channel: LocalImage {
	public func saveLocalImage(_ completion: @escaping ((_ url: URL?, _ error: Error?) -> ())) {
		DispatchQueue.global().async {
			do {
				let data = self.generateImageData()
				try data.write(to: self.singleImageLocalURL)
				DispatchQueue.main.async {
					completion(self.singleImageLocalURL, nil)
				}
			}
			catch {
				DispatchQueue.main.async {
					completion(nil, error)
				}
			}
			
		}
	}
	
	fileprivate func generateImageData() -> Data {
		let height: CGFloat = 608;
		let width = height * 404
		
		let str:NSString = NSString(string: self.title)
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
		
		
		let contextSize = CGSize(width: width, height: height)
		let renderer = UIGraphicsImageRenderer(size: contextSize)
		let textRect = CGRect(origin: CGPoint(x: width/2 - textSize.width/2, y: height/2-textSize.height/2), size: textSize);
		
		let data = renderer.pngData { (context) in
			context.cgContext.setFillColor(UIColor.white.cgColor)
			context.cgContext.fill(CGRect(origin: CGPoint(x:0, y:0), size: contextSize))
			
			context.cgContext.setShouldSmoothFonts(true)
			context.cgContext.setFillColor(UIColor.lightGray.cgColor)
			str.draw(in: textRect, withAttributes: attr)
		}
		
		return data;
	}
	
	public var localImageExists: Bool {
		//		return false
		return FileManager.default.fileExists(atPath: singleImageLocalURL.path);
	}
	
	public var singleImageLocalURL: URL {
		let name = "channel-\(self.sport?.name ?? "unknown")-\(self.identifier)"
		let fileURL = self.getCacheDirectory().appendingPathComponent(name).appendingPathExtension("png")
		return fileURL;
	}
	
	fileprivate func getCacheDirectory() -> URL {
		let paths = FileManager.default.urls(for: .cachesDirectory, in: .userDomainMask)
		let path = paths[0]
		return path;
		//		return path.appendingPathComponent("games", isDirectory: true)
	}
	
}
