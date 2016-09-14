//
//  Environment.swift
//  Pods
//
//  Created by Erik Sargent on 5/2/16.
//
//

open class Environment {
	fileprivate static let currentEnvironment = Environment()
	fileprivate var _environmentDict: [String: AnyObject]? = nil
	
	///Description of the current target
	open static var envDescription: String {
		return Environment.environmentDict["description"] as? String ?? ""
	}
	
	///Loads data from the Target_Name-Env File
	open static var environmentDict: [String: AnyObject] {
		if let environment = currentEnvironment._environmentDict {
			return environment
		}
		
		let bundle = Bundle.main
		let key = kCFBundleNameKey as String
		
		guard let productName = bundle.object(forInfoDictionaryKey: key) as? String else {
			return [:]
		}
		
		let fileName = NSString(format: "%@-Env", productName) as String
		
		guard let filePath = bundle.path(forResource: fileName, ofType: "plist"),
			let dict = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject]
			
			else {
				return [:]
		}
		
		currentEnvironment._environmentDict = dict
		
		return dict
	}
}
