import UIKit
import XCTest
import LKAPI

import Alamofire

class APITests: XCTestCase {
	func testRequestGETSuccess() {
		let expectation = expectationWithDescription("Web request")
		
		let URLRequest = NSMutableURLRequest(URL: NSURL(string: "http://httpbin.org/get")!)
		URLRequest.HTTPMethod = "GET"
		
		API.request(URLRequest, success: { data in
			
			expectation.fulfill()
			XCTAssertNotNil(data)
			
			}, failure: { failure in
				expectation.fulfill()
				XCTFail("Should not have gotten a failure")
		})
		
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testRequestGETFailure() {
		let expectation = expectationWithDescription("Web request")
		
		let URLRequest = NSMutableURLRequest(URL: NSURL(string: "http://httpbin.org/status/400")!)
		URLRequest.HTTPMethod = "GET"
		
		API.request(URLRequest, success: { data in
			
			expectation.fulfill()
			XCTFail("Should not have gotten a success")
			
			}, failure: { failure in
				expectation.fulfill()
				XCTAssertEqual(failure.code, 400)
		})
		
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testRequestPOSTSuccess() {
		let expectation = expectationWithDescription("Web request")
		
		let URLRequest = NSMutableURLRequest(URL: NSURL(string: "http://httpbin.org/post")!)
		URLRequest.HTTPMethod = "POST"
		
		let encoding = Alamofire.ParameterEncoding.JSON
		let formData = ["some": "data"]
		
		API.request(encoding.encode(URLRequest, parameters: formData).0, success: { data in
			
			expectation.fulfill()
			XCTAssertNotNil(data)
			if let data = data as? NSDictionary {
				XCTAssertEqual(data["json"] as? NSDictionary, formData)
			}
			else {
				XCTFail("Unable to cast data")
			}
			
			}, failure: { failure in
				expectation.fulfill()
				XCTFail("Should not have gotten a failure")
		})
		
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testGetRoute() {
		let expectation = expectationWithDescription("Web request")
		
		Router.GetTest.request({ data in
			expectation.fulfill()
			XCTAssertNotNil(data)
		}) { error in
			expectation.fulfill()
			XCTFail("Should not have gotten a failure")
		}
		
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
	
	func testPostRoute() {
		let expectation = expectationWithDescription("Web request")
		
		let formData = ["test": "data"]
		
		Router.PostTest(data: formData).request({ data in
			expectation.fulfill()
			XCTAssertNotNil(data)
			if let data = data as? NSDictionary {
				XCTAssertEqual(data["json"] as? NSDictionary, formData)
			}
			else {
				XCTFail("Unable to cast data")
			}
		}) { error in
			expectation.fulfill()
			XCTFail("Should not have gotten a failure")
		}
		
		waitForExpectationsWithTimeout(5.0, handler: nil)
	}
}


enum Router: Routable {
	case GetTest
	case PostTest(data: [String: AnyObject])
	
	var method: Alamofire.Method {
		switch self {
		case .GetTest:
			return .GET
			
		case .PostTest:
			return .POST
		}
	}
	
	var path: NSURL {
		switch self {
		case .GetTest:
			return NSURL(string: "http://httpbin.org/get")!
			
		case .PostTest:
			return NSURL(string: "http://httpbin.org/post")!
		}
	}
	
	var parameters: [String : AnyObject]? {
		switch self {
		case .PostTest(let data):
			return data
			
		default:
			return nil
		}
	}
}
