import UIKit
import XCTest
import LKAPI

import Alamofire

class APITests: XCTestCase {
	func testRequestGETSuccess() {
		let expectation = self.expectation(description: "Web request")
		
		var urlRequest = URLRequest(url: URL(string: "http://httpbin.org/get")!)
		urlRequest.httpMethod = "GET"
		
		API.request(urlRequest, success: { data in
			
			expectation.fulfill()
			XCTAssertNotNil(data)
			
			}, failure: { failure in
				expectation.fulfill()
				XCTFail("Should not have gotten a failure")
		})
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testRequestGETFailure() {
		let expectation = self.expectation(description: "Web request")
		
		var urlRequest = URLRequest(url: URL(string: "http://httpbin.org/status/400")!)
		urlRequest.httpMethod = "GET"
		
		API.request(urlRequest, success: { data in
			
			expectation.fulfill()
			XCTFail("Should not have gotten a success")
			
			}, failure: { failure in
				expectation.fulfill()
				XCTAssertEqual(failure.code, 400)
		})
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testRequestPOSTSuccess() {
		let expectation = self.expectation(description: "Web request")
		
		var urlRequest = URLRequest(url: URL(string: "http://httpbin.org/post")!)
		urlRequest.httpMethod = "POST"
		
		let encoding = Alamofire.ParameterEncoding.json
		let formData: ModelDict = ["some": "data"]
		
		API.request(encoding.encode(urlRequest, parameters: formData).0, success: { data in
			
			expectation.fulfill()
			XCTAssertNotNil(data)
			if let data = data as? ModelDict, let json = data["json"] as? ModelDict, let some = json["some"] as? String {
				XCTAssertEqual(some, "data")
			}
			else {
				print(data)
				XCTFail("Unable to cast data")
			}
			
			}, failure: { failure in
				expectation.fulfill()
				XCTFail("Should not have gotten a failure")
		})
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testGetRoute() {
		let expectation = self.expectation(description: "Web request")
		
		Router.getTest.request({ data in
			expectation.fulfill()
			XCTAssertNotNil(data)
		}) { error in
			expectation.fulfill()
			XCTFail("Should not have gotten a failure")
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
	
	func testPostRoute() {
		let expectation = self.expectation(description: "Web request")
		
		let formData: ModelDict = ["test": "data"]
		
		Router.postTest(data: formData).request({ data in
			expectation.fulfill()
			XCTAssertNotNil(data)
			if let data = data as? ModelDict, let json = data["json"] as? ModelDict, let test = json["test"] as? String {
				XCTAssertEqual(test, "data")
			}
			else {
				print(data)
				XCTFail("Unable to cast data")
			}
		}) { error in
			expectation.fulfill()
			XCTFail("Should not have gotten a failure")
		}
		
		waitForExpectations(timeout: 5.0, handler: nil)
	}
}


enum Router: Routable {
	case getTest
	case postTest(data: ModelDict)
	
	var method: Alamofire.HTTPMethod {
		switch self {
		case .getTest:
			return .get
			
		case .postTest:
			return .post
		}
	}
	
	var path: URL {
		switch self {
		case .getTest:
			return URL(string: "http://httpbin.org/get")!
			
		case .postTest:
			return URL(string: "http://httpbin.org/post")!
		}
	}
	
	var parameters: ModelDict? {
		if case .postTest(let data) = self {
			return data
		}
		
		return nil
	}
}
