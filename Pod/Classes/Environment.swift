//
//  Environment.swift
//  Pods
//
//  Created by Erik Sargent on 5/2/16.
//
//

public class Environment {
	private static let currentEnvironment = Environment()
	private var _environmentDict: [String: AnyObject]? = nil
	
	///Description of the current target
	public static var envDescription: String {
		return Environment.environmentDict["description"] as? String ?? ""
	}
	
	///Loads data from the Target_Name-Env File
	public static var environmentDict: [String: AnyObject] {
		if let environment = currentEnvironment._environmentDict {
			return environment
		}
		
		let bundle = NSBundle.mainBundle()
		let key = kCFBundleNameKey as String
		
		guard let productName = bundle.objectForInfoDictionaryKey(key) as? String else {
			return [:]
		}
		
		let fileName = NSString(format: "%@-Env", productName) as String
		
		guard let filePath = bundle.pathForResource(fileName, ofType: "plist"),
			dict = NSDictionary(contentsOfFile: filePath) as? [String: AnyObject]
			
			else {
				return [:]
		}
		
		currentEnvironment._environmentDict = dict
		
		return dict
	}
}
