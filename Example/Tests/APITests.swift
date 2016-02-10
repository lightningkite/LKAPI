import UIKit
import XCTest
import LKAPI

import Alamofire

class APITests: XCTestCase {
	func testRequestGETSuccess() {
		let expectation = expectationWithDescription("Web post request")
		
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
		let expectation = expectationWithDescription("Web post request")
		
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
		let expectation = expectationWithDescription("Web post request")
		
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
}
