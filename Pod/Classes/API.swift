//
//  API.swift
//  RAMP
//
//  Created by Erik Sargent on 1/19/16.
//  Copyright © 2016 LightningKite. All rights reserved.
//

import Foundation
import SystemConfiguration

import Alamofire
import LKEnvironment


public typealias successCallback = (AnyObject? -> ())
public typealias failureCallback = (Failure -> ())

public struct Failure {
	public let error: ErrorType
	public let message: String?
	public let code: Int?
	
	public init(error: ErrorType, message: String? = nil, code: Int? = nil) {
		self.error = error
		self.message = message
		self.code = code
	}
}

public enum NetworkError: ErrorType {
	case NoConnection
	case NoDataToMock
	case BadData
}


public protocol Routable: URLRequestConvertible {
	///HTTP Method for the request
	var method: Alamofire.Method { get }
	
	///Path to the endpoint
	var path: NSURL { get }
	
	///Optional parameters to send up with each request
	var parameters: [String: AnyObject]? { get }
	
	///Mock data to return for tests
	var mockData: AnyObject? { get }
}


///Test for network connectivity
public var networkAvailable: Bool {
	var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
	zeroAddress.sin_len = UInt8(sizeofValue(zeroAddress))
	zeroAddress.sin_family = sa_family_t(AF_INET)
	
	guard let defaultRouteReachability = withUnsafePointer(&zeroAddress, {
		SCNetworkReachabilityCreateWithAddress(nil, UnsafePointer($0))
	}) else {
		return false
	}
	
	var flags: SCNetworkReachabilityFlags = []
	if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
		return false
	}
	
	let isReachable = flags.contains(.Reachable)
	let needsConnection = flags.contains(.ConnectionRequired)
	
	return isReachable && !needsConnection
}


public class API {
	///Make a network request based on a route
	public class func request(route: Routable, success: successCallback?, failure: failureCallback?) {
		//Test if the data should be mocked and return the mock data instead
		if Environment.envDescription == "Testing" && route.path.URLString.containsString("mockrequest") {
			if let mockData = route.mockData {
				success?(mockData)
			}
			else {
				failure?(Failure(error: NetworkError.NoDataToMock))
			}
		}
		else {
			request(route.URLRequest, success: success, failure: failure)
		}
	}
	
	
	///Make a general network request
	public class func request(URLRequest: NSURLRequest, success: successCallback?, failure: failureCallback?) {
		//Make sure the network connection is available
		guard networkAvailable else {
			let error = Failure(error: NetworkError.NoConnection)
			failure?(error)
			return
		}
		
		
		var debugString = ""
		if URLRequest.URLRequest.HTTPMethod == "GET" {
			debugString += "⬇️"
		} else {
			debugString += "⬆️"
		}
		
		debugString += Alamofire.request(URLRequest)
			.validate()
			.responseJSON { response in
				
				debugString += response.result.isSuccess ? " ✅" : " ❌"
				print(debugString)
				
				//Make sure there was no error
				guard response.result.isSuccess else {
					//test if the response was 204 (no data), but the validation failed because there was...no data
					if response.response?.statusCode == 204 {
						success?(nil)
					}
						//else there really was an error, so parse any data, and return a failure
					else if let error = response.result.error {
						var message = "There was an error"
						
						do {
							if let data = response.data, values = try NSJSONSerialization.JSONObjectWithData(data, options: .AllowFragments) as? [String: AnyObject] {
								if let error = values["message"] as? String {
									message = error
								}
							}
						} catch _ {
							if let data = response.data, error = String(data: data, encoding: NSUTF8StringEncoding) {
								print(error)
								message = error
							}
						}
						
						print("Status code \(response.response?.statusCode). message: \(message)\n")
						
						failure?(Failure(error: error, message: message, code: response.response?.statusCode))
					}
					
					return
				}
				
				//Otherwise it was a success, so return the data
				success?(response.result.value)
				
			}.description
	}
}
