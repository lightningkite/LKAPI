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


///Successful request callback
public typealias successCallback = ((Any?) -> ())
///Failed request callback
public typealias failureCallback = ((Failure) -> ())
///Represents a header for a request
public typealias HTTPHeader = (field: String, value: String)

///Modal dictionary from the server
public typealias ModelDict = [String: Any]

///Type that can be parsed from JSON
public protocol Parseable {
	static func parse(_ data: Any) -> Parseable?
}

///Type that can be parsed from a ModelDict
public protocol ModelType: Parseable {
	init(data: ModelDict)
	static func parse(_ data: Any) -> Parseable?
}

extension ModelType {
	public static func parse(_ data: Any) -> Parseable? {
		if let data = data as? ModelDict {
			return self.init(data: data)
		}
		
		return nil
	}
}

public extension Dictionary where Key: ExpressibleByStringLiteral, Value: Any {
	///Try to parse an object out of the dictionary, and return the fallback if it fails
	public func parse<T>(_ key: String) -> T? {
		if let dict = self as? ModelDict, let object = dict[key] as? T {
			return object
		}
		
		return nil
	}
	
	///Try to parse an object out of the dictionary, and return the fallback if it fails
	public func parse<T>(_ key: String, or fallback: T) -> T {
		if let dict = self as? ModelDict, let object = dict[key] as? T {
			return object
		}
		
		return fallback
	}
	
	///Parse the field as a Parseable
	public func parse<T>(from key: String) -> T? where T: Parseable {
		if let dict = self as? ModelDict, let object = dict[key] {
			return T.parse(object) as? T
		}
		
		return nil
	}
	
	///Parse the dictionary as a ModelType
	public func parse<T>() -> T? where T: ModelType {
		if let dict = self as? ModelDict {
			return T(data: dict)
		}
		
		return nil
	}
}


///Encapsulates a failed response from a server
public struct Failure {
	public let error: Error
	public let message: String?
	public let code: Int?
	public let data: ModelDict
	
	public init(error: Error, message: String? = nil, code: Int? = nil, data: ModelDict = [:]) {
		self.error = error
		self.message = message
		self.code = code
		self.data = data
	}
}

///Default network ErrorTypes
public enum NetworkError: Error {
	case noConnection
	case noDataToMock
	case badData
}

///Represents a declaration of a Routable network request
public protocol Routable: URLRequestConvertible {
	///HTTP Method for the request
	var method: Alamofire.HTTPMethod { get }
	
	///Path to the endpoint
	var path: URL? { get }
	
	///Optional parameters to send up in the body of each request
	var parameters: ModelDict? { get }
	
	///Optional http headers to send up with each request
	var headers: [HTTPHeader]? { get }
	
	///Mock data to return for tests
	var mockData: String? { get }
	
	///Perform the request for the route
	func request(_ success: successCallback?, failure: failureCallback?)
}

///Default values for many routable properties
public extension Routable {
	///URLRequest object
    public func asURLRequest() throws -> URLRequest {
		guard let path = path else {
			throw AFError.invalidURL(url: "")
		}
		
        var request = URLRequest(url: path)
        request.httpMethod = method.rawValue
        
        if let headers = headers {
            for header in headers {
                request.setValue(header.value, forHTTPHeaderField: header.field)
            }
        }
        
        let encoding = JSONEncoding()
        
        do {
            let encodedRequest = try encoding.encode(request, with: parameters)
            if let requestURL = encodedRequest.urlRequest {
                return requestURL
            }
        } catch { }
        
        return request
    }
	
	///Optional parameters to send up in the body of each request
	var parameters: Parameters? {
		return nil
	}
	
	///Optional http headers to send up with each request
	var headers: [HTTPHeader]? {
		return nil
	}
	
	///Mock data to return for tests
	var mockData: String? {
		return nil
	}
	
	///Perform the request for the route
	func request(_ success: successCallback?, failure: failureCallback?) {
		API.request(self, success: success, failure: failure)
	}
}


///API request manager
open class API {
	///Make a network request based on a route
	open class func request(_ route: Routable, session: SessionManager = Alamofire.SessionManager.default, success: successCallback?, failure: failureCallback?) {
        guard let routeURL = route.urlRequest else {
            
            return
        }
        
		//Test if the data should be mocked and return the mock data instead
		if Environment.envDescription == "Testing" {
			if let mockString = route.mockData, let mockData = API.mockedDataObject(mockString) {
				success?(mockData)
			}
			else {
				request(routeURL, session: session, success: success, failure: failure)
			}
		}
		else {
			request(routeURL, session: session, success: success, failure: failure)
		}
	}
	
	
	///Make a general network request
	open class func request(_ URLRequest: Foundation.URLRequest, session: SessionManager = Alamofire.SessionManager.default, success: successCallback?, failure: failureCallback?) {
		var debugString = ""
		if URLRequest.urlRequest?.httpMethod == "GET" {
			debugString += "⬇️"
		} else {
			debugString += "⬆️"
		}
		
		debugString += session.request(URLRequest)
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
						var responseData = ModelDict()
						
						do {
							if let data = response.data, let values = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? ModelDict {
								responseData = values
								if let error = values["message"] as? String {
									message = error
								}
							}
						} catch _ {
							if let data = response.data, let error = String(data: data, encoding: String.Encoding.utf8) {
								message = error
							}
						}
						
						print("Status code \(response.response?.statusCode ?? -1). message: \(message)\ndata: \(responseData)\n\n")
						
						failure?(Failure(error: error, message: message, code: response.response?.statusCode, data: responseData))
					}
					
					return
				}
				
				//Otherwise it was a success, so return the data
				success?(response.result.value)
				
			}.description
	}
}

///Mocked data for testing requests
public extension API {
	///Load in and parse the stored JSON file
	public class func mockedDataObject(_ path: String) -> Any? {
		do {
			if let dataPath = Bundle.main.path(forResource: path, ofType: "json"), let data = try? Data(contentsOf: URL(fileURLWithPath: dataPath)) {
				let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
				return json
			}
			else {
				print("❌ Unable to load file: \(path)")
				return nil
			}
		}
		catch let exception {
			print("❌ Error occured while parsing JSON", exception)
			return nil
		}
	}
}
