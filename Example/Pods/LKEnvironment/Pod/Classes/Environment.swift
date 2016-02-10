//
//  Environment.swift
//  LKEnvironment
//
//  Created by Lightning Kite on 2/10/2016
//  Copyright (c) 2016 Lightning Kite. All rights reserved.
//

public class Environment {
	private static let currentEnvironment = Environment()
	private var _environmentDict: [String : AnyObject]? = nil
	
	public static var envDescription: String {
		return Environment.environmentDict["description"] as? String ?? ""
	}
	
	public static var environmentDict: [String : AnyObject] {
		if currentEnvironment._environmentDict != nil {
			return currentEnvironment._environmentDict!
		}
		
		let bundle = NSBundle.mainBundle()
		let key = kCFBundleNameKey as String
		let productName = bundle.objectForInfoDictionaryKey(key) as! String
		let fileName = NSString(format: "%@-Env", productName) as String
		let filePath = bundle.pathForResource(fileName, ofType: "plist")
		currentEnvironment._environmentDict = NSDictionary(contentsOfFile: filePath!) as? Dictionary
		
		return currentEnvironment._environmentDict!
	}
}
