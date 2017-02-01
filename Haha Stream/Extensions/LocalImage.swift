import Foundation

protocol LocalImage {
	func saveLocalImage(_ completion: @escaping ((_ url: URL?, _ error: Error?) -> ()));
	var localImageExists: Bool { get };
	var singleImageLocalURL: URL { get }
}
