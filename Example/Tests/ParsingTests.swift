//
//  ParsingTests.swift
//  LKAPI
//
//  Created by Erik Sargent on 8/22/16.
//  Copyright © 2016 CocoaPods. All rights reserved.
//

import UIKit
import XCTest
import LKAPI

import Alamofire

class ParsingTests: XCTestCase {
	func testParseLiteralsFromDictionary() {
		let dict: ModelDict = [
			"int": 5,
			"bool": true,
			"double": 5.5,
			"string": "Hello world!"
		]
		
		XCTAssertEqual(dict.parse("int", or: 0), 5)
		XCTAssertEqual(dict.parse("bool", or: false), true)
		XCTAssertEqual(dict.parse("double", or: 0.0), 5.5)
		XCTAssertEqual(dict.parse("string", or: ""), "Hello world!")
	}
	
	func testParseEmptyLiteralsFromDictionary() {
		let dict: ModelDict = [:]
		
		XCTAssertEqual(dict.parse("int", or: 0), 0)
		XCTAssertEqual(dict.parse("bool", or: false), false)
		XCTAssertEqual(dict.parse("double", or: 0.0), 0.0)
		XCTAssertEqual(dict.parse("string", or: ""), "")
	}
	
	func testParseModelType() {
		struct Type: ModelType {
			let id: Int
			let name: String
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
				name = data.parse("name", or: "")
			}
		}
		
		let dict: ModelDict = [
			"id": 3,
			"name": "Test"
		]
		
		let parsed = dict.parse(Type)
		
		XCTAssertEqual(parsed?.id, 3)
		XCTAssertEqual(parsed?.name, "Test")
	}
	
	func testParseNestedModelType() {
		struct ObjectType: ModelType {
			let id: Int
			let name: String
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
				name = data.parse("name", or: "")
			}
		}
		
		let dict: ModelDict = [
			"object": [
				"id": 3,
				"name": "Test"
			]
		]
		
		let parsed = dict.parse("object", type: ObjectType.self)
		
		XCTAssertEqual(parsed?.id, 3)
		XCTAssertEqual(parsed?.name, "Test")
	}
	
	func testParseParseableDate() {
		let dict: ModelDict = [
			"date": "2222-03-06"
		]
		
		let parsedDate = dict.parse("date", type: NSDate.self)
		
		XCTAssertNotNil(parsedDate)
		guard let date = parsedDate else {
			XCTFail()
			return
		}
		
		let calendar = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
		let components = calendar?.components([.Year, .Month, .Day], fromDate: date)
		
		XCTAssertEqual(components?.year, 2222)
		XCTAssertEqual(components?.month, 3)
		XCTAssertEqual(components?.day, 6)
	}
	
	func testNestedModal() {
		let otherDict: ModelDict = [
			"id": 12
		]
		
		let dict: ModelDict = [
			"id": 3,
			"name": "Test",
			"otherModel": otherDict
		]
		
		struct Modal: ModelType {
			let id: Int
			let name: String
			let other: OtherModel?
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
				name = data.parse("name", or: "")
				other = data.parse("otherModel", type: OtherModel.self)
			}
		}
		
		struct OtherModel: ModelType {
			let id: Int
			
			init(data: ModelDict) {
				id = data.parse("id", or: 0)
			}
		}
		
		let data = dict.parse(Modal)
		
		XCTAssertNotNil(data)
		XCTAssertEqual(data?.id, 3)
		XCTAssertEqual(data?.name, "Test")
		XCTAssertNotNil(data?.other)
		XCTAssertEqual(data?.other?.id, 12)
	}
}

extension NSDate: Parseable {
	public static func parse(data: AnyObject) -> Parseable? {
		let dateFormatter = NSDateFormatter()
		dateFormatter.dateFormat = "yyyy-MM-dd"
		
		if let dateString = data as? String, date = dateFormatter.dateFromString(dateString) {
			return date
		}
		
		return nil
	}
}
